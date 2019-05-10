const path = require('path')
const webpack = require('webpack')
const CopyWebpackPlugin = require("copy-webpack-plugin");

module.exports = {
  entry: {
    "app.js": "./src/index.js"
  },
  output: {
    path: path.join(__dirname, "../priv/static/js"),
    filename: '[name]'
  },
  resolve: {
    alias: {
      '@pages': path.resolve(__dirname, 'src', 'pages'),
      '@components': path.resolve(__dirname, 'src', 'components'),
      '@utils': path.resolve(__dirname, 'src', 'utils'),
      '@images': path.resolve(__dirname, 'src', 'images'),
    }
  },
  devtool: 'cheap-module-source-map',
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: require.resolve('babel-loader')
      },
      {
        test: /\.css$/,
        use: [
          require.resolve('style-loader'),
          require.resolve('css-loader')
        ]
      },
      {
        test: [/\.eot$/, /\.ttf$/, /\.woff$/, /\.woff2$/, /\.png$/],
        loader: require.resolve('file-loader'),
        options: {
          name: 'static/media/[name].[hash:8].[ext]',
        },
      },
      {
        test: /images\/.*\.svg(\?.*)?$/,
        use: [
          'svg-react-loader',
          'svg-transform-loader',
          {
            loader: 'svgo-loader',
            options: {
              plugins: [
                {
                  prefixIds: true,
                },
                {
                  removeViewBox: false,
                },
                {
                  removeDimensions: true,
                },
              ],
            },
          },
        ],
      },
      {
        test: /\.svg$/,
        exclude: [path.resolve('src/images/')],
        use: ['babel-loader', 'react-svg-loader']
      }
    ]
  },
  plugins: [
    new CopyWebpackPlugin([{ from: "./static", to: path.join(__dirname, "../priv/static") }]),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': `"${process.env.NODE_ENV}"`
    }),
  ]
};
