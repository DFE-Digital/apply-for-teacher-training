## GOV.UK One Login Configuration and Setup

To set up the configuration correctly, follow these steps:

1. **Create an Account**
   - [Create an account](https://admin.sign-in.service.gov.uk/sign-in/enter-email-address) on the GOV.UK One Login service.

2. **Create Your Service**
   - After creating your account, create your service for the application that will use this configuration.

3. **Setup Omniauth Configuration**
   - The setup within `lib/omniauth/onelogin_setup.rb` can mostly be copied. However, you need to specify the `redirect_uri` and `post_logout_redirect_uri` specific to your application.

4. **Configure OneLogin Issuer URI**
   - The `onelogin_issuer_uri` is the GOV.UK One Login service URL with which we are communicating. For testing purposes, use `https://oidc.integration.account.gov.uk/`. For production use, you will need to request production access, which will provide a different issuer. Ensure you add this to the `GOVUK_LOGIN_ISSUER_URL` environment variable.

5. **Generate Private and Public Keys**
   - Run the following commands to generate both your private and public keys:
     ```sh
     openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
     openssl rsa -pubout -in private_key.pem -out public_key.pem
     ```
   - [Generate a key](https://docs.sign-in.service.gov.uk/before-integrating/generate-a-key/) for more details.

6. **Add Public Key to Console**
   - Once generated, add the `public_key` to the Public Key field in the console.

7. **Set Environment Variables**
   - Add the public key to the `GOVUK_LOGIN_PUBLIC_KEY` environment variable.
   - Add the private key to the `GOVUK_LOGIN_PRIVATE_KEY` environment variable.

8. **Test**
     - If all was setup correctly, when you attempt to sign in, you should be redirected and prompted to enter a username and password to authenticate against the `https://oidc.integration.account.gov.uk/`. The details can be found in the (admin console)[https://admin.sign-in.service.gov.uk/services]

By following these steps, you will have correctly configured your application to use the GOV.UK One Login service.
