# Life is Skill iOS App

[![Build Status](https://img.shields.io/travis/com/username/repository.svg)](https://travis-ci.com/username/repository)  
[![License](https://img.shields.io/github/license/username/repository.svg)](./LICENSE.md)

## Description

This app was created as part of Bachelor Thesis "Application Life is Skill for iOS Platform version 2", whose author is Karolína Droscová, completed at the Faculty of Informatics at CTU. 
 
> This work is an iOS application for organization Life is Skill that mimics the functionalities in their Android app. The purpose is to enable users to participate in the organizations's competitions.

> This work builds on the bachelor’s thesis “Life is Skill Application for iOS” by Ing. Rostislav Babáček, which was created in 2020 at CTU FIT ([full text available here](https://dspace.cvut.cz/handle/10467/88721))

### Life is Skill

Life is Skill is a non-profit organization based in the Czech Republic, aiming to encourage children, youth, and even adults to engage in more active lifestyles by reducing screen time and promoting real-world activities. Through a fun competition system, participants earn points by exploring nature, attending sports events, and visiting cultural activities. The more points participants collect, the higher their chances of winning exciting prizes.

Life is Skill’s mission is to motivate people of all ages to embrace outdoor activities and cultural experiences as a path to a healthier and more active life.

For more information, visit Life is Skill’s [official website](https://www.lifeisskill.cz).

---

## Table of Contents
- [Installation](#installation)
- [Features](#features)
- [Usage](#usage)
- [Configuration](#configuration)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

---

## Installation

### Prerequisites
- **Xcode** (latest stable version recommended, available on the Mac App Store)
- **Swift** (Swift 5.0)
- **Carthage**:  
  You can install Carthage using Homebrew:
  ```bash
  brew install carthage
  ```

### Steps

#### 1. Clone the repository:
   ```bash
   git clone https://github.com/k-droscova/lifeisskill.git
   cd lifeisskill
   ```

#### 2. Install dependencies using **Carthage with XCFrameworks**.
  1. Update Carthage dependencies and build XCFrameworks:  
     Run the following command to update dependencies and build them as XCFrameworks:
     ```bash
     carthage update --use-xcframeworks --platform iOS
     ```
  2. Integrate Carthage XCFrameworks into Xcode:
     - Open Xcode and go to your project settings.
     - Under the General tab, scroll down to Frameworks, Libraries, and Embedded Content.
     - Click the + button and select the XCFrameworks located in the Carthage/Build folder (should be: Realm.xcframework and RealmSwift.xcframework). Select the option Embed & Sign.

#### 3. Install dependencies using **Swift Package Manager**.
In Xcode, go to **File > Swift Packages > Add Package Dependency** and add the following packages:
- ACKategories, from url: "https://github.com/AckeeCZ/ACKategories.git"
- Swift Algorithms, from Apple Swift Packages in the left side menu.

#### 4. Adjust app configuration file (see Configuration)

#### 5. Build and run the app using `Cmd + R`.

---

## Features

- **Feature 1**: Login using existing Life is Skill account, register as a new user, or reset your password.
- **Feature 2**: Scan points from QR, NFC and Tourist Signs.
- **Feature 3**: See game data (your collected points, rankings within categories, and map with all game points)
- **Feature 4**: See your profile info, and complete registration in your profile if you haven't done so.
- **Feature 5**: Invite friends into the game using QR code.

---

## Usage

1. Launch the app on your iOS device or simulator.
2. Sign in using the your credentials or create a new account.
3. Start scanning points!

---

## Configuration

1. **Create a `config.xcconfig` file**:

   Since the configuration file is not included in the repository, you need to create one manually with the following format:

   ##### Required (minimum) `config.xcconfig` format:

   ```plaintext
   API_BASE_URL = <base url for requests for data>
   API_DETAIL_URL = <url for sponsor images>
   API_QR_URL = <url for qr code generation for inviting friends>
   API_KEY = <your api key>
   AUTH_TOKEN = <your api auth token>
   KEYCHAIN_USERNAME_KEY = <key for storing username of logged in user in keychain>
   KEYCHAIN_PASSWORD_KEY = <key for storing password of logged in user in keychain>
   REALM_FILE = <your realm file extension>
   MAP_VIRTUAL_POINT = <distance under which the app detects a preesence of virtual point nearby>
   PIN_VALIDITY_TIME = <how long is the pin valid when you request password reset>
   ```
  Replace the placeholder values (e.g., <your-api-base-url>) with your actual API keys, URLs, and configuration details.
  You can add more configurations in this file and then adjusting Info.plist file to use environment variables. 
  
2. **Ensure that the scheme you are using for build uses this configuration file**:
   
   Follow these steps to ensure your Xcode scheme is configured properly:

   1. Open **Xcode** and navigate to the project’s **scheme selector** (located next to the play/stop buttons at the top left of Xcode).
   
   2. Select **Edit Scheme** from the dropdown.

   3. In the **Edit Scheme** dialog, select the **Build** tab from the left panel.

   4. On the right side, under **Build Configuration**, ensure that the correct configuration (e.g., `Debug`, `Release`) is selected.

   5. Go to **File > Project Settings** (or **Workspace Settings** if it's a workspace) and verify that your `config.xcconfig` file is associated with the appropriate build configuration.

   6. If needed, assign the `xcconfig` file to the configuration in the **Project Settings**:
      - Select your project in the project navigator (left side of Xcode).
      - Go to the **Info** tab.
      - Under **Configurations**, ensure that the appropriate `xcconfig` file is selected for each configuration (e.g., `Debug`, `Release`).

3. **Save your changes** and re-run the build.

---

## Testing

1. Run unit tests:
   ```bash
   Cmd + U
   ```

2. Run UI tests with the simulator or real device selected:
   ```bash
   Cmd + U
   ```

---

## Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

Please make sure to read the [contributing guidelines](./CONTRIBUTING.md) before submitting a pull request.

---

## License

This project is licensed under the **Mozilla Public License 2.0**. See the [LICENSE](./LICENSE.md) file for more details.

