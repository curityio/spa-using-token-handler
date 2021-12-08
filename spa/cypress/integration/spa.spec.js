import {
  BASE_URL,
  TIMEOUT_100,
  authenticateUser,
  signOutUser,
  clickElement } from './spa';

describe('Single Page App Tests', () => {
  beforeEach(() => {
    cy.intercept('/tokenhandler/**', (req) => {
      req.headers['Origin'] = 'http://www.example.com'
    });
    cy.visit(BASE_URL);
    clickElement('#startAuthentication');
    authenticateUser();
  });

  afterEach(() => {
    signOutUser();
  });

  it('Get user info and call APIs from the application', () => {
    clickElement('#getUserInfo');
    cy.get('#getUserInfoResult')
        .wait(TIMEOUT_100)
        .contains('Demo User');
    clickElement('#getApiData');
    cy.get('#getDataResult')
        .wait(TIMEOUT_100)
        .contains('Success response from the Business API');
  })

})
