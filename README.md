![MSIX](https://user-images.githubusercontent.com/946652/138101650-bf934b21-ced7-4836-a197-2e424ee1f86c.png)

<a href="https://flutter.dev/docs/development/packages-and-plugins/favorites" title="Flutter Favorite program">
<img
  src="https://user-images.githubusercontent.com/946652/152225760-309041e9-266e-42da-9915-34478ee74736.png"
  alt="Flutter Favorite Badge"
  align="right">
</a>

[![pub package](https://img.shields.io/pub/v/msix.svg?color=blue)](https://pub.dev/packages/msix) [![MSIX toolkit package](https://img.shields.io/github/v/tag/microsoft/MSIX-Toolkit?color=blue&label=MSIX-Toolkit)](https://github.com/microsoft/MSIX-Toolkit) [![issues-closed](https://img.shields.io/github/issues-closed/YehudaKremer/msix?color=green)](https://github.com/YehudaKremer/msix/issues?q=is%3Aissue+is%3Aclosed) [![issues-open](https://img.shields.io/github/issues-raw/YehudaKremer/msix)](https://github.com/YehudaKremer/msix/issues) [![Codemagic build status](https://api.codemagic.io/apps/61fc249977f79ce332414c45/61fc249977f79ce332414c44/status_badge.svg)](https://codemagic.io/apps/61fc249977f79ce332414c45/61fc249977f79ce332414c44/latest_build)

[MSIX] is a Windows app packaging format from Microsoft that combines the best
features of MSI, .appx, App-V, and ClickOnce to provide a modern and reliable
packaging experience.

This package offers a command line tool for creating MSIX installers from your
Flutter app, making it easy to [publish your app to the Microsoft Store] or host
it on a website.

## :clipboard: Installation

In your `pubspec.yaml`, add the `msix` package as a new [dev dependency] with
the following command:

```console
PS c:\src\flutter_project> flutter pub add --dev msix
```

## :package: Creating an MSIX installer

To create a MSIX installer, run the following command:

```console
PS c:\src\flutter_project> flutter pub run msix:create
```

## ![github settings icon][] Configuring your installer

You will almost certainly want to customize various settings in the MSIX
installer, such as the application title, the default icon, and which [Windows
capabilities] your application needs. You can customize the generated MSIX
installer by adding declarations to an `msix_config:` node in your
`pubspec.yaml` file:

```yaml
msix_config:
  display_name: Flutter App
  publisher_display_name: Company Name
  identity_name: company.suite.flutterapp
  msix_version: 1.0.0.0
  logo_path: C:\path\to\logo.png
  capabilities: internetClient, location, microphone, webcam
```
See [Configurations Examples And Use Cases].

### Available Configurations

<details>

<summary>MSIX configuration (click to expand)</summary>

| YAML name                | Command-line argument                | Description (from Microsoft [Package manifest schema reference])                                                                                      | Example                                                                                         |
| ------------------------ | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `display_name`           | `--display-name` `-d`                | A friendly app name that can be displayed to users.                                                                                                   | `Flutter App`                                                                               |
| `publisher_display_name` | `--publisher-display-name` `-u`      | A friendly name for the publisher that can be displayed to users.                                                                                     | `Company Name`                                                                                        |
| `identity_name`          | `--identity-name` `-i`               | Defines the unique identifier for the app.                                                                                                            | `company.suite.flutterapp`                                                                           |
| `msix_version`           | `--version`                          | The version number of the package, in `a.b.c.d` format.                                                                                               | `1.0.0.0`                                                                                       |
| `logo_path`              | `--logo-path` `-l`                   | Path to an [image file] for use as the app icon (size recommended at least 400x400px).                                                                                 | `C:\images\logo.png`                                                                         |
| `trim_logo`              | `--trim-logo <true/false>`           | If `false`, don't trim the logo image, default is `true`.                                                                                             | `true`                                                                                          |
| `capabilities`           | `--capabilities` `-e`                | List of the [capabilities][windows capabilities] the app requires.                                                                                    | `internetClient,location,microphone,webcam`                                                     |
| `languages`              | `--languages`                        | Declares the language resources contained in the package.                                                                                             | `en-us, ja-jp`                                                                                  |
| `file_extension`         | `--file-extension` `-f`              | File extensions that the app may be registered to open.                                                                                               | `.picture, .image`                                                                              |
| `protocol_activation`    | `--protocol-activation`              | [Protocols activation] that will activate the app.                                                                                                         | `http,https`                                                                                         |
| `execution_alias`    | `--execution-alias`              | [Execution alias] command (cmd) that will activate the app. | `myapp`                                                                                          |
| `enable_at_startup`    | `--enable-at-startup`              | App start at startup or user log-in. | `true`                                                                                          |
| `store`                  | `--store`                            | Generate a MSIX file for publishing to the Microsoft Store.                                                                                           | `false`                                                                                         |

</details>

<details>
<summary>Build configuration (click to expand)</summary>

| YAML name                | Command-line argument                | Description                                                                                      | Example                                                                                         |
| ------------------------ | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `debug`                  | `--debug` or `--release`             | Create MSIX from the **debug** or **release** build files (`\build\windows\runner\<Debug/Release>`), **release** is the default.                                 | `true`                                                                                          |
| `output_path`            | `--output-path` `-o`                 | The directory where the output MSIX file should be stored.                                                                                            | `C:\src\some\folder`                                                                             |
| `output_name`            | `--output-name` `-n`                 | The filename that should be given to the created MSIX file.                                                                                           | `flutterApp_dev`                                                                                     |
| `architecture`           | `--architecture` `-h`                | Describes the architecture of the code in the package, `x64` or `x86`, `x64` is default.                                                                                               | `x64`                                                                                           |
| `build_windows`          | `--build-windows <true/false>`       | If `false`, don't run the build command `flutter build windows`, default is `true`.                                                                   | `true`                                                                                          |

</details>

<details>
<summary>Sign configuration (click to expand)</summary>

| YAML name                | Command-line argument                | Description                                                                                      | Example                                                                                         |
| ------------------------ | ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `certificate_path`       | `--certificate-path` `-c`            | Path to the certificate content to place in the store.                                                                                                | `C:\certs\signcert.pfx`                                                                         |
| `certificate_password`   | `--certificate-password` `-p`        | Password for the certificate.                                                                                                                         | `1234`                                                                                          |
| `publisher`              | `--publisher` `-b`                   | The `Subject` value in the certificate.                                                                                                               | `CN=BF212345-5644-46DF-8668-014043C1B138` or `CN=Contoso Software, O=Contoso Corporation, C=US` |
| `signtool_options`       | `--signtool-options`                 | Options to be provided to the `signtool` for app signing (see below.)                                                                                 | `/v /fd SHA256 /f C:/Users/me/Desktop/my.cer`                                                   |
| `sign_msix`    | `--sign-msix <true/false>` | If `false`, don't sign the msix file, default is `true`.                                                                                         | `true`                                                                                          |
| `install_certificate`    | `--install-certificate <true/false>` | If `false`, don't try to install the certificate, default is `true`.                                                                                         | `true`                                                                                          |

</details>

<details>

<summary>Toast Notifications configuration (click to expand)</summary>

##### [Toast Notifications] configuration example:

```yaml
msix_config:
  display_name: Flutter App
  toast_activator: #<-- toast notifications configuration
    clsid: A1232234-1234-1234-1234-123412341234
    arguments: "1,2,3"
    display_name: "TEST"
  msix_version: 1.0.3.0
```

| YAML name      | Command-line argument                 | Description                               | Example                                |
| -------------- | ------------------------------------- | ----------------------------------------- | -------------------------------------- |
| `clsid`        | `--toast-activator-clsid` `-d`        | The UUID CLSID.                           | `replaced-with-your-guid-C173E6ADF0C3` |
| `arguments`    | `--toast-activator-arguments`         | Arguments for the toast notifications.    | `----AppNotificationActivationServer`  |
| `display_name` | `--toast-activator-display-name` `-d` | Display name for the toast notifications. | `Toast activator`                      |

</details>

### Msix Version

The MSIX installer version number is used to determine updates to the app and consists of 4 numbers (`1.0.0.0`).

<details>

<summary>See more details on how to set the msix version (click to expand)</summary>

#### The version is determined by the first available option:

1. Command line `--version` flag
2. In `pubspec.yaml`, under the `msix_config` node, the `msix_version` value
3. Using the `version` field in `pubspec.yaml`.
   - The Pubspec version uses [semver], which is of the form `major.minor.patch-prerelease+build`
   - `msix` will use the `major.minor.patch` and append a `0` for the MSIX version
   - All prerelease and build info is discarded
4. Fallback to `1.0.0.0`

By default, if you have a valid `version` in your `pubspec.yaml` file, that will form the basis for your MSIX installer version.

</details>

## :black_nib: Signing options

Published MSIX installers should be [signed with a certificate], to help ensure
that app installs and updates come from trustworthy sources.

- For development purposes, this package is configured by default to
  automatically sign your app with a [self signed] **test certificate**, which makes it easy
  to test your install prior to release.
- If you publish your app to the **Microsoft Store**, the installation package
  will be signed automatically by the store.
- If you need to use your **own signing certificate**, for example to release
  the app outside of the Microsoft Store, you can use the configuration fields
  `certificate_path` and `certificate_password` to configure a certificate of
  your choice.

You can also provide custom options to the signing tool with the
`--signtool-options` command, as shown above. For more information on available
options, see the [signtool documentation]. Note that using this option overrides
the `certificate_path` and `certificate_password` fields.

**Note**: By default, the MSIX package will install the certificate on your
machine. You can disable this by using the `--install-certificate false` option, or the YAML
option `install_certificate: false`.

## ![microsoft store icon][] Publishing to the Microsoft Store

To generate an MSIX file for publishing to the Microsoft Store, use the
`--store` flag, or alternatively add `store: true` to the YAML configuration.

**Note**: For apps published to the Microsoft Store, the configuration values
`publisher_display_name`, `identity_name`, `msix_version` and `publisher` must
all be configured and should match the registered publisher and app name from
the [Microsoft Store dashboard], as per [this screenshot].

## :globe_with_meridians: Publishing outside the store

You can use the [App Installer] file to enable your users to install and update the app from local file share.

Note: installing from the web `ms-appinstaller:` is [disabled] for now.

To create a App Installer file, first set the `publish_folder_path` configuration,
then run the following command:

```console
PS c:\src\flutter_project> flutter pub run msix:publish
```

<details>
<summary>Available configurations for App Installer (click to expand)</summary>

##### App Installer configuration example:

```yaml
msix_config:
  display_name: Flutter App
  app_installer: #<-- app installer configuration
    publish_folder_path: c:\path\to\myPublishFolder
    hours_between_update_checks: 0
    automatic_background_task: true
    update_blocks_activation: true
    show_prompt: true
    force_update_from_any_version: false
  msix_version: 1.0.3.0
```

| YAML name                       | Command-line argument             | Description (from Microsoft [schema reference])                                                                                                    | Example                      |
| ------------------------------- | --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| `publish_folder_path`           | `--publish-folder-path`           | A path to publish folder, where the msix versions and the .appinstaller file will be saved.                                                        | `c:\path\to\myPublishFolder` |
| `hours_between_update_checks`   | `--hours-between-update-checks`   | Defines the minimal time gap between update checks, when the user open the app. default is **0** (will check for update every time the app opened) | `2`                          |
| `automatic_background_task`     | `--automatic-background-task`     | Checks for updates in the background every 8 hours independently of whether the user launched the app.                                             | `false`                      |
| `update_blocks_activation`      | `--update-blocks-activation`      | Defines the experience when an app update is checked for.                                                                                          | `false`                      |
| `show_prompt`                   | `--show-prompt`                   | Defines if a window is displayed when updates are being installed, and when updates are being checked for.                                         | `false`                      |
| `force_update_from_any_version` | `--force-update-from-any-version` | Allows the app to update from version x to version x++ or to downgrade from version x to version x--.                                              | `false`                      |

</details>

---

Tags: `msi` `windows` `win10` `win11` `windows10` `windows11` `windows store` `windows installer` `windows packaging` `appx` `AppxManifest` `SignTool` `MakeAppx`

[msix]: https://docs.microsoft.com/en-us/windows/msix/
[publish your app to the microsoft store]: https://docs.microsoft.com/en-us/windows/uwp/publish/app-submissions
[dev dependency]: https://dart.dev/tools/pub/dependencies#dev-dependencies
[windows capabilities]: https://docs.microsoft.com/en-us/windows/uwp/packaging/app-capability-declarations
[package manifest schema reference]: https://docs.microsoft.com/en-us/uwp/schemas/appxpackage/appxmanifestschema/schema-root
[schema reference]: https://docs.microsoft.com/en-us/uwp/schemas/appinstallerschema/element-onlaunch
[app installer]: https://docs.microsoft.com/en-us/windows/msix/app-installer/app-installer-file-overview
[image file]: https://github.com/brendan-duncan/image#supported-image-formats
[protocols activation]: https://docs.microsoft.com/en-us/windows/uwp/launch-resume/handle-uri-activation
[execution alias]: https://docs.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-uap5-executionalias
[signed with a certificate]: https://docs.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing
[signtool documentation]: https://docs.microsoft.com/en-us/dotnet/framework/tools/signtool-exe
[microsoft store icon]: https://user-images.githubusercontent.com/946652/152312614-1e86b108-98af-4bcf-8a75-d7a4449078b2.png
[github settings icon]: https://user-images.githubusercontent.com/946652/152312495-173eb794-337c-4630-a149-2167810614ae.png
[microsoft store dashboard]: https://partner.microsoft.com/dashboard
[this screenshot]: https://user-images.githubusercontent.com/946652/138753431-fa7dee7d-99b6-419c-94bf-4514c761abba.png
[toast notifications]: https://docs.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/send-local-toast-desktop-cpp-wrl#msixsparse-package
[disabled]: https://docs.microsoft.com/en-us/windows/msix/app-installer/installing-windows10-apps-web
[self signed]: https://docs.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing#create-a-self-signed-certificate
[Configurations Examples And Use Cases]: https://pub.dev/packages/msix/example
[semver]: https://semver.org/
