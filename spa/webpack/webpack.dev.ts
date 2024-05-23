import path from 'path';
import webpack from 'webpack';
import {merge} from 'webpack-merge';
import common from './webpack.common.js';

const dirname = process.cwd();
const devConfig: webpack.Configuration = {

  mode: 'development',
  devServer: {
    static: {
        directory: path.join(dirname, './dist'),
    },
    port: 80,
    hot: true,
    allowedHosts: [
        'www.example.com'
    ],
  },
}

export default merge(common, devConfig);
