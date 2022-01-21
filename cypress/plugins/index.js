/// <reference types="cypress" />
// ***********************************************************
// This example plugins/index.js can be used to load plugins
//
// You can change the location of this file or turn off loading
// the plugins file with the 'pluginsFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/plugins-guide
// ***********************************************************

// This function is called when a project is opened or re-opened (e.g. due to
// the project's config changing)
const util = require("util");
const NotifyClient = require("notifications-node-client").NotifyClient;

const sleep = util.promisify(setTimeout);

const ONE_HOUR = 60 * 60 * 1000;
const SECONDS_BETWEEN_NOTIFY_ATTEMPTS = 1;

const hasCorrectSubject = notifyEmail =>
  notifyEmail["subject"].includes("Sign in to apply for teacher training") ||
  notifyEmail["subject"].includes("Please confirm your email address");

const wasCreatedInTheLastHour = notifyEmail =>
  new Date() - new Date(notifyEmail["created_at"]) < ONE_HOUR;

const signInEmailFor = emailAddress => notifyEmail =>
  notifyEmail["email_address"] === emailAddress &&
  hasCorrectSubject(notifyEmail) &&
  wasCreatedInTheLastHour(notifyEmail);

const extractSignInLink = notifyEmail => notifyEmail.body.match(/https.*/)[0];

/**
 * @type {Cypress.PluginConfig}
 */
module.exports = (on, config) => {
  const notifyClient = new NotifyClient(config.env["GOVUK_NOTIFY_API_KEY"]);

  const getNotifyEmailFor = async (emailAddress, retries = 5) => {
    const response = await notifyClient.getNotifications("email");
    const notifications = response.data.notifications;
    let notifyEmail = notifications.find(signInEmailFor(emailAddress));

    if (!notifyEmail && retries > 0) {
      console.log(
        "Could not find sign in email for %s, retrying %d time(s). Waiting %d second(s).",
        emailAddress,
        retries,
        SECONDS_BETWEEN_NOTIFY_ATTEMPTS
      );
      await sleep(SECONDS_BETWEEN_NOTIFY_ATTEMPTS * 1000);
      notifyEmail = await getNotifyEmailFor(emailAddress, retries - 1);
    }

    return notifyEmail;
  };

  on("task", {
    getSignInLinkFor({ emailAddress }) {
      return new Promise(async (resolve, reject) => {
        try {
          const notifyEmail = await getNotifyEmailFor(emailAddress);

          resolve(extractSignInLink(notifyEmail));
        } catch (err) {
          console.error("Error in getSignInLinkFor:", err);

          reject(err);
        }
      });
    },

    log(message) {
      console.log(message);

      return null;
    },

    table(message) {
      console.table(message);

      return null;
    }
  });
};
