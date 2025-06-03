# Simulated-Email-Service-Application

## 📬 Introductions

Simulated Email Service is a learning-orieneted application that allows you to view, compose, send, reply, forward emails, etc. This application is built based on real-life application **Gmail** so basically the system functional are on the same up to 70%. Built with Flutter, Firebase and modern backend technologies, this app offers a realistics email experience which perfect for developers, students, and anyone who interested in understanding how an email system work behind the scenes.

## 🔑 Key Features
- Internal email sending and receiving
- Auto-reply for incoming messages (using Firebase function)
- Email categorization, read/unread status, starring
- Notify for new incoming emails
- User interface inspired by Gmail for famaliar UX
- Built using Flutter and Firebase (Firestore, Cloud Functions, Pub/Sub, FCM)

## 🎯 Purpose

The goal of this application is to provide a **safe**, **simulated environment** for:

- Explore and understand the architecture of real-world email services
- Practicing event-driven systems and microservices patterns using Pub/Sub
- Experimenting with real-time updates and notification flows
- Learning to handle user authentication, OTP, permission, and data state in email-based application

## 🔧 Implementation 

This application is typically implemented by using Flutter framework built based on Dart programming language. Beside that, the project also using Cloud Functions by Firebase to deploy some functions for some specific features on the app. 

For data storing, Firebase is also our options for this project because of its convenience. We divide models and store them on Firestore Database as collections. Some can list as

- users 
- emails
- drafts

### The project structure on overview

We just list some important directories for the implementation

```
Simulated-Email-Service-Application/
├── functions                   // this includes deployed functions 
├── lib                         // this stored the project code (important)
└── pubspec.yaml                // config file of project (include used dependencies)
```

Move into `functions/` this directory structure includes

```
functions/
├── autoReply/
│   ├── processAutoReply.js     // process auto reply function
│   └── scheduleAutoReply.js    // schedule auto reply email function
├── notifications/
│   └── notifyNewEmail.js       // notify if has new email function
├── utils/
│   └── pubsub.js               // pubsub utils for functions above
├── firebase.js                 // firebase initialization file
├── index.js                    // index file import all functions above
└── package.json                // package the modules
```

And the main directory of the project `lib/`

```
lib/
├── core/                       // include the global variable
│   ├── config
│   ├── constants
│   └── state
├── features                    // include main feature of app
│   ├── email
│   └── notification
└── main.dart                   // main file of running app
```

The most important one in this project is the `email/` directory

```
email/
├── controllers                 // project controller
├── models                      // project models
├── providers                   // providers
├── utils                       // utilities
└── views                       // interfaces
    ├── screens                 // screens
    └── widgets                 // supportive widgets
```

## 💾 Installation

To install this project, we just need to clone this project from our github repository. You can access this repository on github by [Simulated-Email-Service-Application](https://github.com/giahao1411/Simulated-Email-Service-Application). 

After that, on the near middle right corner, you can find the button with **`<> Code`** there where we going to install this project. Click on that and select the options to clone. As usual of me, I'm going to clone the project with **"HTTPS"** options, copy the code or there you go.

```
https://github.com/giahao1411/Simulated-Email-Service-Application.git
```

You got the code, then open your CLI or Terminal or PowerShell, whatever you want as long as it have the permission to runs the code. Type:

```bash
git clone <the code you copied before>
```

There you go, you have cloned the project from github.

## 🚀 Run the Program

First thing first, on opening the application on CLI or any IDE if you are developers. The most important thing whenever clone and run a project/repository is to re-download the used dependencies. Don't worry we have listed all the needed dependencies for this project. On this project Flutter with Dart based, run this command to download the dependencies. 

```bash
flutter pub get
```

Congratulations, you have done the first step of re-downloading the dependencies. Let get into the `functions/` directory by

```bash
cd funtions
```

In this directory, the used modules are packaged on package.json. To download it, run

```bash
npm install
```

After waiting for so long (or just my device experienced it) the dependencies is downloaded. On the next step to run the program, because of the cross platform support so you can choose on which platform you can start the program on.

- Web Application
- Windows Application
- Android Application

Run this command to start the program

```bash
flutter run
```

If you have chosen Window or Web, the application going to start soon. For andriod platform, you have to start the device before running. You can start your device on Intellij Idea but need some kit as Android Studio.

You can start a device on Visual Studio Code IDE also as long as you have installed the Flutter/Dart extensions. Start on **"Ctrl + Shift + P"** then type

```
>Flutter: Select Device 
```

or 

```
>Flutter: Launch Emulator
```

If you caught any trouble on running on Android platform, run this command on CLI

```bash
flutter doctor
```

to get the issuses and resolve them.

Wish you the best wishes and luck. Happy experiencing our Email Application.

## 📜 License

This project is licensed under the [MIT License](./LICENSE).

## ✍️ Authors 

- [nhathao512](https://github.com/nhathao512)
- [huyblue17](https://github.com/huyblue17)
- [giahao1411](https://github.com/giahao1411)
