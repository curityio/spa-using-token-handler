# Web Host

The web host is a very simple component that only handles a few concerns by default:

- Serving static web content when index.html is requested
- Writing recommended security headers

This requires only limited code execution capabilities.\
The SPA can then be deployed anywhere, such as to a Content Delivery Network.