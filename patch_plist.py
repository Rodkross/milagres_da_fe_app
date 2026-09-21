with open('ios/Runner/Info.plist', 'r') as f:
    content = f.read()

if 'NSPhotoLibraryUsageDescription' not in content:
    replacement = """	<key>NSPhotoLibraryUsageDescription</key>
	<string>O aplicativo precisa de acesso à galeria para você poder atualizar sua foto de perfil.</string>
	<key>NSCameraUsageDescription</key>
	<string>O aplicativo precisa de acesso à câmera para você poder tirar uma foto de perfil.</string>
	<key>NSMicrophoneUsageDescription</key>
	<string>O aplicativo precisa de acesso ao microfone caso você grave vídeos na câmera.</string>
</dict>
</plist>"""
    content = content.replace("</dict>\n</plist>", replacement)
    
    with open('ios/Runner/Info.plist', 'w') as f:
        f.write(content)
