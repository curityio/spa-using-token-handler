import {
  BASE_URL,
  ORIGIN,
  authenticateUser,
  signOutUser,
  clickElement
} from './spa';

describe('Single Page App Tests', () => {
  beforeEach(() => {
    cy.intercept('/tokenhandler/**', (req) => {
      req.headers['Origin'] = ORIGIN;
    }).as('tokenHandlerCall');
    cy.intercept('/api/**', (req) => {
      req.headers['Origin']  = ORIGIN
    }).as('businessApiCall');
    cy.visit(BASE_URL);
    authenticateUser();
  });

  afterEach(() => {
    signOutUser();
  });

  it('Get user info and call APIs from the application', () => {
    clickElement('#getUserInfo');
    cy.get('#getUserInfoResult')
        .contains('Demo User');
    clickElement('#getApiData', true);
    cy.get('#getDataResult')
        .contains('Success response from the Business API');
  })

})
