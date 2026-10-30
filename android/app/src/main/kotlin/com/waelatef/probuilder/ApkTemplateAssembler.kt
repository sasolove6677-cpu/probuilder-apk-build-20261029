package com.waelatef.probuilder

import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.FilterOutputStream
import java.io.IOException
import java.io.OutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream

/** Repackages a template APK while replacing only its bundled HTML entry. */
internal object ApkTemplateAssembler {
    private const val HTML_ENTRY = "assets/index.html"
    private const val ICON_ENTRY = "res/drawable-nodpi/launcher.png"
    private const val STORED_ENTRY_ALIGNMENT = 4L
    private const val ZIPALIGN_EXTRA_FIELD_ID = 0xD935

    fun injectHtml(templateApk: File, htmlFile: File, unsignedApk: File, iconFile: File? = null) {
        if (!templateApk.isFile || !templateApk.canRead()) {
            throw IOException("The APK template is missing or unreadable.")
        }
        if (!htmlFile.isFile || !htmlFile.canRead()) {
            throw IOException("The selected HTML file is missing or unreadable.")
        }

        unsignedApk.parentFile?.let { parent ->
            if (!parent.exists() && !parent.mkdirs()) {
                throw IOException("Unable to create the temporary build directory.")
            }
        }

        var insertedHtml = false
        ZipInputStream(BufferedInputStream(FileInputStream(templateApk))).use { input ->
            val countedOutput = CountingOutputStream(
                BufferedOutputStream(FileOutputStream(unsignedApk)),
            )
            ZipOutputStream(countedOutput).use { output ->
                var sourceEntry = input.nextEntry
                while (sourceEntry != null) {
                    when {
                        isOldSignature(sourceEntry.name) -> input.closeEntry()
                        sourceEntry.name == HTML_ENTRY -> {
                            if (!insertedHtml) {
                                writeHtml(output, htmlFile)
                                insertedHtml = true
                            }
                            input.closeEntry()
                        }
                        isIconEntry(sourceEntry.name) && iconFile != null -> {
                            writeIcon(output, iconFile, sourceEntry.name)
                            input.closeEntry()
                        }
                        else -> {
                            copyEntry(input, output, sourceEntry, countedOutput.bytesWritten)
                            input.closeEntry()
                        }
                    }
                    sourceEntry = input.nextEntry
                }

                if (!insertedHtml) {
                    writeHtml(output, htmlFile)
                }
            }
        }
    }

    private fun copyEntry(
        input: ZipInputStream,
        output: ZipOutputStream,
        source: ZipEntry,
        currentOffset: Long,
    ) {
        val target = ZipEntry(source.name).apply {
            time = source.time
            comment = source.comment
            if (source.method == ZipEntry.STORED) {
                if (source.size < 0L || source.crc < 0L) {
                    throw IOException("Template contains an invalid stored ZIP entry: ${source.name}")
                }
                method = ZipEntry.STORED
                size = source.size
                compressedSize = source.size
                crc = source.crc
                extra = alignmentExtra(source.name, currentOffset)
            } else {
                method = ZipEntry.DEFLATED
            }
        }
        output.putNextEntry(target)
        if (!source.isDirectory) input.copyTo(output, DEFAULT_BUFFER_SIZE)
        output.closeEntry()
    }

    private fun alignmentExtra(name: String, localHeaderOffset: Long): ByteArray? {
        val nameLength = name.toByteArray(Charsets.UTF_8).size
        val dataOffsetWithoutExtra = localHeaderOffset + LOCAL_FILE_HEADER_SIZE + nameLength
        if (dataOffsetWithoutExtra % STORED_ENTRY_ALIGNMENT == 0L) return null

        val paddingBytes = (
            STORED_ENTRY_ALIGNMENT -
                ((dataOffsetWithoutExtra + EXTRA_FIELD_HEADER_SIZE) % STORED_ENTRY_ALIGNMENT)
            ).toInt() % STORED_ENTRY_ALIGNMENT.toInt()
        return ByteArray(EXTRA_FIELD_HEADER_SIZE.toInt() + paddingBytes).apply {
            this[0] = (ZIPALIGN_EXTRA_FIELD_ID and 0xff).toByte()
            this[1] = ((ZIPALIGN_EXTRA_FIELD_ID ushr 8) and 0xff).toByte()
            this[2] = (paddingBytes and 0xff).toByte()
            this[3] = 0
        }
    }

    private fun writeHtml(output: ZipOutputStream, htmlFile: File) {
        val target = ZipEntry(HTML_ENTRY).apply {
            method = ZipEntry.DEFLATED
            time = System.currentTimeMillis()
        }
        output.putNextEntry(target)
        FileInputStream(htmlFile).buffered().use { it.copyTo(output, DEFAULT_BUFFER_SIZE) }
        output.closeEntry()
    }

    private fun isIconEntry(name: String): Boolean =
        name == ICON_ENTRY || name == "res/drawable-nodpi-v4/launcher.png"

    private fun writeIcon(output: ZipOutputStream, iconFile: File, entryName: String) {
        val target = ZipEntry(entryName).apply {
            method = ZipEntry.DEFLATED
            time = System.currentTimeMillis()
        }
        output.putNextEntry(target)
        FileInputStream(iconFile).buffered().use { it.copyTo(output, DEFAULT_BUFFER_SIZE) }
        output.closeEntry()
    }

    private fun isOldSignature(name: String): Boolean {
        if (!name.startsWith("META-INF/", ignoreCase = true)) return false
        val leaf = name.substringAfterLast('/')
        if (leaf.isBlank() || leaf.contains('/')) return false
        return leaf.equals("MANIFEST.MF", ignoreCase = true) ||
            leaf.endsWith(".SF", ignoreCase = true) ||
            leaf.endsWith(".RSA", ignoreCase = true) ||
            leaf.endsWith(".DSA", ignoreCase = true) ||
            leaf.endsWith(".EC", ignoreCase = true) ||
            leaf.startsWith("SIG-", ignoreCase = true)
    }

    private class CountingOutputStream(output: OutputStream) : FilterOutputStream(output) {
        var bytesWritten: Long = 0
            private set

        override fun write(value: Int) {
            out.write(value)
            bytesWritten++
        }

        override fun write(buffer: ByteArray, offset: Int, length: Int) {
            out.write(buffer, offset, length)
            bytesWritten += length
        }
    }

    private const val LOCAL_FILE_HEADER_SIZE = 30L
    private const val EXTRA_FIELD_HEADER_SIZE = 4L
}
