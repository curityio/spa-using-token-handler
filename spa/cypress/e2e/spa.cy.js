import {
  BASE_URL,
  ORIGIN,
  authenticateUser,
  signOutUser,
  clickElement
} from './spa';

describe('Single Page App Tests', () => {
  beforeEach(() => {
    cy.intercept('/oauth-agent/**', (req) => {
      req.headers['Origin'] = ORIGIN;
    }).as('oauthAgentCall');
    cy.intercept('/api/**', (req) => {
      req.headers['Origin']  = ORIGIN
    }).as('businessApiCall');
    cy.visit(BASE_URL);
    authenticateUser();
  });

  afterEach(() => {
    signOutUser();
  });

  it('Login then get ID token claims, user info and call APIs from the application', () => {
    
    clickElement('#getUserInfo');
    cy.get('#getUserInfoResult')
        .contains('Demo User');
    clickElement('#getClaims');
    cy.get('#getClaimsResult')
        .contains('auth_time');
    clickElement('#getApiData', true);
    cy.get('#getDataResult')
        .contains('Success response from the Business API');
  })

})
