import webpack from 'webpack';
import {merge} from 'webpack-merge';
import common from './webpack.common.js';

const prodConfig: webpack.Configuration = {
  mode: 'production',
}

export default merge(common, prodConfig)
