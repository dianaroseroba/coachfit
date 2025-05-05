# 🏊‍♀️ CoachFit IA

**CoachFit IA** es una aplicación móvil desarrollada con **Flutter + Dart**, enfocada en deportistas nadadores que buscan registrar, visualizar y analizar sus entrenamientos. Utiliza **Appwrite** como backend para autenticación y almacenamiento seguro de datos.

---

## 🚀 Características

- ✅ Registro diario de entrenamientos: minutos, distancia (m), calorías.
- ✅ Visualización del historial de entrenos.
- ✅ Filtro por semana.
- ✅ Gráfico de barras de minutos entrenados por día (`fl_chart`).
- ✅ Sistema de autenticación (login/registro) usando Appwrite.
- ✅ Navegación estructurada con `GetX`.
- 🔜 Integración futura con IA para generar mensajes motivacionales según tu rendimiento.

---

## 📦 Tecnologías utilizadas

- [Flutter](https://flutter.dev/)
- [Appwrite](https://appwrite.io/)
- [GetX](https://pub.dev/packages/get)
- [fl_chart](https://pub.dev/packages/fl_chart)

---

## 🧱 Estructura de carpetas (Clean Architecture)

lib/
├── controllers/ # Controladores GetX
├── core/
│ ├── config/ # Configuración Appwrite
│ └── constants/ # Constantes globales (IDs, endpoints)
├── data/
│ └── repositories/ # Comunicación con Appwrite
├── model/ # Modelos de datos (User, Workout)
├── presentation/
│ └── pages/ # UI (login, register, splash, workout)
└── main.dart # Entrada principal

---

## 🛠️ Configuración local

1. Clona el repositorio:
   ```bash
   git clone https://github.com/dianaroseroba/coachfit.git
   cd coachfit
