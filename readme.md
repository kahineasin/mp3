## web.config
�ڸ߰汾IIS�п��ܲ���Ҫ�����mime����(д�˷������ͻ,��ΪĬ�Ͼ�����)
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <directoryBrowse enabled="true" />
        <staticContent>
            <!-- <mimeMap fileExtension=".aac" mimeType="audio/aac" /> -->
            <mimeMap fileExtension=".lrc" mimeType="text/plain" />
            <!-- <mimeMap fileExtension=".mp4" mimeType="video/mp4" /> -->
        </staticContent>
    </system.webServer>
</configuration>
