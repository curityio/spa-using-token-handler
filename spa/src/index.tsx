
import React from 'react';
import ReactDOM from 'react-dom';
import App from './views/app/app';
import {AppViewModel} from './views/app/appViewModel';

const props = {
    viewModel: new AppViewModel(),
};

ReactDOM.render(
    <App {...props} />,
    document.getElementById('root'),
);
