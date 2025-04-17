
import React from 'react';
import {createRoot} from 'react-dom/client';
import App from './views/app/app';
import {AppViewModel} from './views/app/appViewModel';

const props = {
    viewModel: new AppViewModel(),
};

const container = document.getElementById('root');
const root = createRoot(container!);
root.render(<App {...props} />);
