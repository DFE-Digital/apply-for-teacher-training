const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        jquery: 'jquery'
    })
)

// Set quietDeps option on dart-sass (see
// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#silence-deprecation-warnings-from-dependencies-in-dart-sass)
const sassLoaderConfig = environment.loaders.get('sass').use.find(el => el.loader === 'sass-loader')
sassLoaderConfig.options.implementation = require('sass')
sassLoaderConfig.options.sassOptions = {
  quietDeps: true,
}

module.exports = environment
