// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './priv/source/**/*.html.slim',
    './lib/blog/**/*.ex'
  ],
  theme: {
    extend: {
      colors: {
        'light-olive': '#f0f0d0',
        olive: '#808000',
        'dark-olive': '#556b2f',
        'very-dark-olive': '#323f1b'
      },
      width: {
        200: '50rem'
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    plugin(({addVariant}) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({addVariant}) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({addVariant}) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({addVariant}) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']))
  ]
}
