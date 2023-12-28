const { merge } = require('webpack-merge');
const common = require('./webpack.common.js');
const path = require('path');

module.exports = merge(common, {

  mode: 'development',
  devServer: {
    static: {
        directory: path.join(__dirname, '../dist'),
    },
    port: 80,
    hot: true,
    allowedHosts: [
        'www.example.com'
    ],
  },
})
