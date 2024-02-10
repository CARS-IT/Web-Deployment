# Web-Deployment

![License](https://img.shields.io/badge/license-MIT-orange.svg)

This repository contains the necessary files and documentation for deploying some of the GSECARS web applications.

------------
## Table of Contents

- [WordPress](#wordpress-deploymentmigration)
- [Contributing](#contributing)
- [License](#license)

------------
## WordPress Deployment/Migration

This project is able to deploy and migrate WordPress websites to docker containers. It generates a .env file with all the necessary information, a docker_compose file, and an apache configuration file. Using the docker_compose it deploys two containers, one for WordPress and one for MySQL. Follow the steps below, to deploy or migrate a WordPress website.

Before you begin, first you must clone the repository:
```bash
git clone -b development https://github.com/GSECARS/Web-Deployment.git && cd Web-Deployment
```

Run the main project script and follow the instructions for deploying or migrating a WordPress website.
```bash
sudo ./web-deployment.sh
```

## Contributing

All contributions to the Web-Deployment project are welcome! Here are some ways you can help:
- Report a bug by opening an [issue](https://github.com/GSECARS/Web-Deployment/issues).
- Add new features, fix bugs or improve documentation by submitting a [pull request](https://github.com/GSECARS/Web-Deployment/pulls).

Please adhere to the [GitHub flow](https://docs.github.com/en/get-started/quickstart/github-flow) model when making your contributions! This means creating a new branch for each feature or bug fix, and submitting your changes as a pull request against the main branch. If you're not sure how to contribute, please open an issue and we'll be happy to help you out.

By contributing to the Web-Deployment project, you agree that your contributions will be licensed under the MIT License.

[back to top](#table-of-contents)

------------
## License

Web-Deployment is distributed under the MIT license. You should have received a [copy](LICENSE) of the MIT License along with this program. If not, see https://mit-license.org/ for additional details.