# Bypass API Support Page

Welcome to the Bypass API Support Page! We’re here to guide you through our application and help you leverage its features effectively. Below, you will find a range of topics and common queries about our app.

## Getting Started

1. [Installing Bypass API](#installing-bypass-api).

## FAQ

1. [Understanding Bypass API functionality](#understanding-bypass-api-functionality).
2. [Creating and Sending a Request in Bypass API](#creating-a-request-in-bypass-api).

## Advanced Guides

1. [Integrating Bypass API with Shortcuts](#integrating-bypass-api-with-shortcuts).
2. [Maintaining security with Bypass API](#maintaining-security-with-bypass-api).

## Other Resources

1. [Bypass API Documentation](#bypass-api-documentation).
2. [Terms of Service and Privacy Policy](#terms-of-service-and-privacy-policy).

Can’t find the help you need? Feel free to [contact our support team,](#contact-support) and we'll be happy to assist you.

***

### Installing Bypass API
You can download Bypass API from [Test Flight](https://testflight.apple.com/join/0gP0Qmic). Compatible with iOS 16.5 and later versions. 

### Understanding Bypass API Functionality
The Bypass API serves as a repository for your custom requests, enabling you to send them and read the responses directly within the app. Additionally, it allows your stored APIs to interact with Apple's Shortcuts App. Detailed information about this can be found in [here](#using-bypass-api-with-apples-shortcuts-app).

### Creating a Request in Bypass API
To utilize Bypass API, you must first create a request. This involves selecting the HTTP method, assigning an identifying name, and inputting a URL. These fields are required for saving the request. Optionally, headers and a content body can also be included. Currently, the content body supports JSON Body and Multi-Form with string values only. Once the URL and Name are not defined you can start send them by pressing the button at the bottom of the new request form.

### Integrating Bypass API with Shortcuts

Bypass can send your request directly from the app. It integrates a secondary feature that allows you to interact with the Shortcuts App. To fully implement it follow the steps below:

1. Download the Shortcuts App from [Test Flight](https://testflight.apple.com/join/0gP0Qmic).
2. Open the Shortcuts App.
3. Tap the plus (+) button to create a new shortcut.
4. Open the 'Search for apps and actions' section.
5. Select 'Bypass API' from the list of actions.
6. Choose the 'Send request' option.
7. Enter the name of the request you want to call in the 'service' section.

After executing the shortcut, you will receive the response text from the request.
For more detailed guidance on creating shortcuts, visit [here](https://support.apple.com/guide/shortcuts/intro-to-shortcuts-apdf22b0444c/ios).

### Maintaining Security with Bypass API
While Bypass API does not track your information, it is up to the user to manage the personal information they input into the app and the services they connect to.

### Bypass API Documentation
Bypass API, being an open-source project, encourages active community participation and knowledge sharing. For comprehensive understanding, technical specifications, and in-depth exploration of our project, visit our official [GitHub repository](https://github.com/javier-games/bypass-api). Here, you will find detailed documentation, insights into the project's architecture, and discussion threads to aid in your use and potential contribution to the Bypass API.

### Terms of Service and Privacy Policy
By using Bypass API, you agree to our [Terms of Service](TERMS_AND_CONDITIONS.md) and [Privacy Policy](PRIVACY_POLICY.md). Please make sure to read and understand them.

### Contact Support
Should you require any additional assistance, our dedicated support team is ready to help. Please reach out to us by sending an email to [support@javier.games](mailto:support@javier.games). We also encourage you to leverage our open-source community on GitHub. You're welcome to open a [new issue](https://github.com/javier-games/bypass-api/issues/new) in our public repository for feature requests or to report any issues you encounter while using the Bypass API.