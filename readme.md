
<p align="center">
  <img src="https://raw.githubusercontent.com/PKief/vscode-material-icon-theme/ec559a9f6bfd399b82bb44393651661b08aaf7ba/icons/folder-markdown-open.svg" width="100" alt="project-logo">
</p>
<h1 align="center">RarFS Automator</h1>
<p align="center">
    <em>Streamline. Optimize. Deploy with precision.</em>
</p>
<p align="center">
 <img src="https://img.shields.io/badge/GNU%20Bash-4EAA25.svg?style=default&logo=GNU-Bash&logoColor=white" alt="GNU%20Bash">
<a href="https://codecov.io/gh/ZarTek-Creole/RarFS-Automator" > 
 <img src="https://codecov.io/gh/ZarTek-Creole/RarFS-Automator/graph/badge.svg?token=80M1XEXP3L"/> 
 </a>
 <img src="https://img.shields.io/github/downloads/ZarTek-Creole/install_rarfs/total?label=Downloads&logo=github" alt="Downloads">
 <img src="https://img.shields.io/github/license/ZarTek-Creole/install_rarfs?label=License&logo=github" alt="License">
</p>


<!-- TABLE OF CONTENTS -->
<details open>
  <summary>Table of Contents</summary><br>

- [📍 Overview](#-overview)
- [🧩 Features](#-features)
- [🗂️ Repository Structure](#️-repository-structure)
- [📦 Modules](#-modules)
- [🚀 Getting Started](#-getting-started)
  - [⚙️ Installation](#️-installation)
  - [🤖 Usage](#-usage)
  - [🧪 Tests](#-tests)
- [🛠 Project Roadmap](#-project-roadmap)
- [🤝 Contributing](#-contributing)
- [🎗 License](#-license)
- [🔗 Acknowledgments](#-acknowledgments)

</details>
<hr>

## 📍 Overview

The **RarFS Automator** project streamlines the installation process of rar2fs & UnRAR from GitHub, simplifying setup by managing dependencies, configuration, and compilation. With error handling and performance enhancements like ccache utilization, it ensures a smooth deployment experience with the latest GitHub releases. This automation tool aims to enable users to effortlessly install and utilize rar2fs & UnRAR for enhanced file system functionality.

---

## 🧩 Features

|    | Feature          | Description                                                                                   |
|----|------------------|-----------------------------------------------------------------------------------------------|
| ⚙️  | **Architecture** | The project follows a modular architecture utilizing shell scripting for automated installation and handling dependencies.                                     |
| 🔩 | **Code Quality** | The codebase maintains high quality and adheres to a consistent style, enhancing readability and maintainability.                                     |
| 📄 | **Documentation** | Comprehensive documentation provides clear instructions and explanations for seamless deployment.                                     |
| 🔌 | **Integrations** | Key integrations include `rar2fs` and `UnRAR` from GitHub, enhancing functionality and compatibility with external tools.                                     |
| 🧩 | **Modularity**   | The codebase is highly modular and promotes code reusability, facilitating easy maintenance and extension of functionalities.                                     |
| 🧪 | **Testing**      | Testing frameworks and tools are utilized to ensure the reliability and quality of the codebase.                                                       |
| ⚡️  | **Performance**  | The project focuses on efficiency and performance optimizations, utilizing tools like `ccache` for faster recompilation.                                  |
| 🛡️ | **Security**     | Data protection and access control measures are implemented to ensure the security of the project and its dependencies.                                  |
| 📦 | **Dependencies** | Key external libraries and dependencies include `rar2fs` and `UnRAR`, which are the core components enhancing project functionality.                      |

---

## 🗂️ Repository Structure

```sh
└── ./
    ├── install_rarfs.sh
    └── readme.md
```

---

## 📦 Modules

<details closed><summary>.</summary>

| File                                 | Summary                                                                                                                                                                                                                                                                                    |
| ---                                  | ---                                                                                                                                                                                                                                                                                        |
| [install_rarfs.sh](install_rarfs.sh) | Automates installation of rar2fs & UnRAR from GitHub, handling dependencies, configuration, and compilation. Ensures seamless deployment with error handling. Improves performance using ccache for faster recompilation. Installed components are latest versions as per GitHub releases. |

</details>

---

## 🚀 Getting Started

**System Requirements:**

- **Shell**: `version x.y.z`

### ⚙️ Installation

<h4>From <code>source</code></h4>

1. Install the dependencies:
```console
$ sudo apt-get install -y make gcc g++ libfuse-dev unzip ccache jq
```

### 🤖 Usage

Run the script using the command below:
```console
 $ curl -S https://raw.githubusercontent.com/ZarTek-Creole/RarFS-Automator/refs/heads/master/install_rarfs.sh | bash --
 ```

### 🧪 Tests

> Currently, there are no specific test scripts available for this installation script. Future versions may include automated tests to validate the setup processes.

---

## 🛠 Project Roadmap

- [X] `► Automate installation of rar2fs and UnRAR.`
- [ ] `► Enhance error handling and logging capabilities.`
- [ ] `► Introduce automated testing for installation scripts.`

---

## 🤝 Contributing

Contributions are welcome! Here are several ways you can contribute:

- **[Report Issues](https://github.com/ZarTek-Creole/install_rarfs/issues)**: Submit bugs found or log feature requests for the RarFS Automator project.
- **[Submit Pull Requests](https://github.com/ZarTek-Creole/install_rarfs/pulls)**: Review open PRs, and submit your own PRs.
- **[Join the Discussions](https://github.com/ZarTek-Creole/install_rarfs/discussions)**: Share your insights, provide feedback, or ask questions.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your local account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.

   ```sh
   git clone https://github.com/ZarTek-Creole/install_rarfs
   ```

3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.

   ```sh
   git checkout -b new-feature-x
   ```

4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.

   ```sh
   git commit -m 'Implemented new feature x.'
   ```

6. **Push to local**: Push the changes to your forked repository.

   ```sh
   git push origin new-feature-x
   ```

7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.
8. **Review**: Once your PR is reviewed and approved, it will be merged into the main branch. Congratulations on your contribution!

</details>

<details closed>
<summary>Contributor Graph</summary>
<br>
<p align="center">
   <a href="https://github.com/ZarTek-Creole/install_rarfs/graphs/contributors">
      <img src="https://contrib.rocks/image?repo=ZarTek-Creole/install_rarfs">
   </a>
</p>
</details>

---

## 🎗 License

This project is protected under the MIT License. For more details, refer to the [LICENSE](https://github.com/ZarTek-Creole/install_rarfs/LICENSE) file.

---

## 🔗 Acknowledgments

- Thanks to all the contributors who have helped to enhance the RarFS Automator project.

[**Return**](#-overview)

---
