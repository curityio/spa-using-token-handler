import { defineConfig } from "cypress";

export default defineConfig({
  chromeWebSecurity: false,
  viewportWidth: 1920,
  viewportHeight: 1080,
  defaultCommandTimeout: 10000,
  videosFolder: "cypress/reports/videos",
  screenshotsFolder: "cypress/reports/screenshots",
  videoUploadOnPasses: false,
  retries: 1,
  reporter: "mochawesome",

  reporterOptions: {
    reportDir: "cypress/reports/separate-reports",
    overwrite: false,
    html: false,
    json: true,
  },

  env: {
    ORIGIN: 'https://www.example.com',
    LOGIN_START_URL: 'https://api.example.com/oauth-agent/login/start',
    IDSVR_BASE_URL: 'https://login.example.com:8443',
  },

  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
});
