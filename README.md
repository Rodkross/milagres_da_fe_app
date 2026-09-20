# Milagres da Fé App 🙏🕊️

O aplicativo oficial do Ministério Milagres da Fé. Construído com Flutter e Firebase, ele foi projetado para engajar a igreja de forma moderna, oferecendo uma experiência premium (estética Navy Deep & Gold) que conecta os irmãos, aprofunda o estudo da palavra e facilita o dia a dia da congregação.

## 🚀 Funcionalidades Principais

### 📖 Versículo do Dia Sincronizado
- Sorteio determinístico: Todos os usuários do aplicativo recebem exatamente o mesmo versículo a cada dia.
- O sorteio é recalibrado pontualmente à meia-noite (Horário de Brasília / UTC-3).
- **Sistema de Curtidas Global:** Os usuários podem curtir o versículo do dia. O coração acende para todos em tempo real através do Firebase Firestore, e o estado da curtida é salvo na memória local do aparelho (`SharedPreferences`) para persistência vitalícia para aquele versículo específico.

### 🧠 Devocional com Inteligência Artificial
- Integração profunda com o modelo **Google Gemini 1.5 Flash**.
- Ao clicar no versículo, a IA atua como um pastor teólogo e gera um estudo estruturado contendo: Contexto Histórico, Apoio Exegético, e Aplicação Pessoal.
- **Versículos Relacionados Inteligentes:** A IA sugere passagens relacionadas. Estas passagens são botões interativos ("Chips") que, ao serem tocados, varrem o banco de dados interno da Bíblia JFA e abrem diretamente no capítulo exato para leitura in-app.

### 🙏 Mural de Oração (Intercessão)
- Um mural em tempo real onde a igreja pode colocar pedidos de oração (Públicos ou restritos à Liderança).
- **Botão "Vou Orar":** Um contador comunitário. Ao clicar, o Firebase soma +1 no contador do pedido. O celular registra localmente o engajamento e o botão é substituído por um selo permanente "Você orou ✅".

### ☕ Convênio da Cantina (Extrato Inteligente)
- Interface no modelo de extrato bancário para controle de contas na cantina da igreja.
- Agrupamento em "Acordeões" automáticos separados por mês (Mês atual sempre aberto por padrão).
- Cálculo de "Saldo Progressivo" linha a linha: mostra exatamente como estava o saldo após cada consumo (vermelho) ou pagamento (verde).

### 👤 Perfil do Membro Avançado
- Integração com `image_picker` e **Firebase Storage** para envio de foto de perfil na nuvem.
- Integração via API REST (`http`) com a base do **ViaCEP**: Basta o membro digitar o CEP e o aplicativo preenche Rua, Bairro e Cidade automaticamente.

### 🎨 Design System e Identidade Visual
- **Cores Principais:** Navy Deep (`#0B132B`) e Gold Bright (`#E4A42C`).
- Sombras suaves (blur de luxo), modais arredondados de 24px e tipografias elegantes (`Georgia` para leitura bíblica).
- Ícone e Tela de Abertura (Splash Screen) gerados sob medida por Inteligência Artificial generativa, proporcionando transição invisível (edge-to-edge).

## 🛠️ Tecnologias Utilizadas

- **Frontend:** Flutter & Dart
- **Backend & Banco de Dados:** Firebase Authentication, Cloud Firestore, Firebase Storage
- **Persistência Local:** SharedPreferences
- **Inteligência Artificial:** `google_generative_ai` (Gemini API)
- **APIs Externas:** ViaCEP (Geolocalização BR)
- **Ícones e Assets:** `flutter_launcher_icons`, `flutter_native_splash`

## 📦 Como rodar o projeto

1. Faça o clone do repositório.
2. Certifique-se de que os pacotes estão atualizados rodando: `flutter pub get`.
3. *(Opcional)* Caso tenha alterado as imagens de ícone, rode `flutter pub run flutter_launcher_icons` e `flutter pub run flutter_native_splash:create` para recriá-los.
4. Conecte seu emulador ou dispositivo físico e rode: `flutter run`.

---
*Construído com excelência técnica e direcionamento para fortalecer a comunidade.*
