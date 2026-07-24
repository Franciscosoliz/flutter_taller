# Taller Mecanico App

Aplicacion movil multiplataforma desarrollada en Flutter para la gestion y seguimiento integral de servicios, ordenes de trabajo, diagnosticos y citas dentro de un taller mecanico. Disenada para ofrecer una experiencia fluida tanto a clientes como al personal administrativo y mecanicos del taller.

---

## Vista Previa

| Login & Autenticacion | Panel Principal | Ordenes & Servicios |
| :---: | :---: | :---: |
| <img width="230" alt="Login" src="https://github.com/user-attachments/assets/828df624-847d-4513-b922-b555de597a5f" /> | <img width="230" alt="Panel Principal" src="https://github.com/user-attachments/assets/c08db8ae-fd7e-4886-9e43-4d3c4a25fefb" /> | <img width="230" alt="Ordenes" src="https://github.com/user-attachments/assets/1f805ee8-88a1-46e6-8de7-91f4685a9d25" /> |

---

## Caracteristicas Principales

* **Autenticacion Segura (JWT):** Inicio de sesion con almacenamiento seguro en dispositivo (`flutter_secure_storage`) y renovacion automatica de sesion via Refresh Token.
* **Control de Roles:** Interfaces adaptadas segun el tipo de usuario (Clientes y Personal Staff / Administradores).
* **Gestion de Ordenes de Trabajo:** Seguimiento del historial de estados de las ordenes, vehiculos y diagnosticos tecnicos.
* **Catalogo de Vehiculos y Servicios:** Consulta de marcas, modelos, clientes y recomendaciones de mantenimiento preventivo.
* **Interceptor de Red Avanzado:** Manejo global de peticiones HTTP con Dio, reintentos automaticos y tratamiento estandarizado de errores backend.

---

## Tecnologias Utilizadas

* **Framework:** Flutter
* **Lenguaje:** Dart
* **Gestion de Estado:** Riverpod
* **Cliente HTTP:** Dio
* **Almacenamiento Local Seguro:** Flutter Secure Storage
* **Backend:** REST API construida en Django / Django REST Framework con JWT

---

## Estructura del Proyecto

El proyecto sigue los principios de la Clean Architecture dividida por capas:

```text
lib/
├── core/                  # Configuraciones globales, temas y constantes de la app
│   └── config/
├── data/                  # Capa de datos (fuentes locales y remotas)
│   ├── local/             # FlutterSecureStorage y persistencia
│   └── remote/            # Cliente Dio e Interceptores HTTP
├── domain/                # Modelos de dominio y logica de negocio
│   └── model/
├── presentation/          # Interfaz de usuario y estado (UI & State)
│   ├── providers/         # Providers de Riverpod
│   └── screens/           # Pantallas principales
└── main.dart              # Punto de entrada de la aplicacion
