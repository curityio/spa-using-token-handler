/*
 * Copyright 2021 Curity AB
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export const TIMEOUT_100 = 100;
export const TIMEOUT_500 = 500;
export const TIMEOUT_1000 = 1000;
export const ORIGIN = Cypress.env('ORIGIN') || 'http://www.example.com';
export const BASE_URL = ORIGIN + '/';
export const LOGIN_START_URL = Cypress.env('LOGIN_START_URL') || 'http://api.example.com:3000/oauth-agent/login/start';
export const IDSVR_BASE_URL = Cypress.env('IDSVR_BASE_URL') || 'http://login.example.com:8443';
export const USERNAME = 'demouser';
export const PASSWORD = 'Password1';

export function authenticateUser() {
    cy.request({
        // Get the authorization URL from the OAuth Agent
        method: 'POST',
        url: LOGIN_START_URL,
        headers: { Origin: ORIGIN }
    })
    .then(response => {
        // Call the authorization URL
        return cy.request({
            method: "POST",
            url: response.body.authorizationRequestUrl,
            followRedirect: true
        })
    })
    .then(response => {
        const jqueryHtml = getHTMLBodyAsJQueryDOM(response.body);
        const action = jqueryHtml.find('form').attr('action');

        // Post username and password
        return cy.request({
            method: "POST",
            url: IDSVR_BASE_URL + action,
            body: { userName: USERNAME, password: PASSWORD },
            form: true,
            followRedirect: true
        })
    })
    .then(response => {
        const jqueryHtml = getHTMLBodyAsJQueryDOM(response.body)
        // For some reason jQuery can't find the form element, but it finds a div inside of the form...
        const form = jqueryHtml.find('#noscript').parent();
        const action = form.attr('action');
        const token = form.find('input[name="token"]').val();
        const state = form.find('input[name="state"]').val();

        // Submit the final form (normally this is done by JS in the browser)
        return cy.request({
            method: "POST",
            url: IDSVR_BASE_URL + action,
            body: { token, state },
            form: true,
            followRedirect: false
        })
    })
    .then(resp => {
        // Navigate to the redirect URL to finish login
        return cy.visit(resp.redirectedToUrl)
    })
    .then(() => {
        cy.url().should('eq', BASE_URL);
        cy.get('#getUserInfo')
            .should('exist')
    })
}

export function signOutUser() {
    clickElement('#signOut');
    cy.get('#startAuthentication')
        .should('exist');
}

export function inputText(selector, text) {
    cy.get(selector)
        .click({ force: true })
        .clear()
        .type(text);
}

export function clickElement(selector, apiCall = false, clickOptions = null) {
    const waitForCall = apiCall ? '@businessApiCall' : '@oauthAgentCall';
    cy.get(selector)
        .should('exist')
        .click(clickOptions)
        .wait(waitForCall);
}

function getHTMLBodyAsJQueryDOM(body) {
    return Cypress.$(body);
}
