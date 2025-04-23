# 🍞 CeliApp

**CeliApp** é um aplicativo mobile desenvolvido com Flutter que tem como objetivo facilitar o dia a dia de pessoas com doença celíaca. O app permite que usuários gerenciem suas listas de compras e receitas, além de escanear produtos para identificar a presença de glúten.

---

## 📱 Tecnologias Utilizadas

- **Frontend:** Flutter + Dart
- **Backend:** Node.js + PostgreSQL
- **Serviços em nuvem:** Firebase (Auth, Firestore, etc.)
- **Scanner de produtos:** Plugin de leitura de código de barras
- **Gerenciamento de estado:** [Provider / BLoC / outro] *(especifique qual está usando)*

---

## 🧩 Funcionalidades

- ✅ **Lista de Compras** – Adicione produtos com segurança para uma dieta sem glúten.
- ✅ **Lista de Receitas** – Salve, edite e organize receitas, gere listas de compras de acordo com os igredientes requeridos.
- ✅ **Escaneamento de Produtos** – Verifique rapidamente se um item contém glúten ao escanear o código de barras.
- 🔒 **Autenticação de Usuário** – Login/cadastro com Firebase Auth.
- ☁️ **Sincronização em Nuvem** – Dados armazenados no Firebase Firestore.
- 🌐 **Integração com banco de dados de ingredientes e produtos** *(futuramente)*

---

## 🧱 Arquitetura

```text
Flutter App → Firebase (Auth + Firestore)
             ↘
              → Node.js API → PostgreSQL

