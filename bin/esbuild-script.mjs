import esbuild from 'esbuild'
import manifestPlugin from 'esbuild-plugin-manifest'
import {sassPlugin} from 'esbuild-sass-plugin'

const logLevel = process.env.ESBUILD_LOG_LEVEL || 'silent'
const watch = !!process.env.ESBUILD_WATCH

const jsPath = 'priv/source/javascripts/application.js'

const config = {
  logLevel,
  entryPoints: {
    app: jsPath
  },
  bundle: true,
  outdir: './build',
  target: 'esnext',
  entryNames: 'assets/[name]-[hash]',
  metafile: true,
  publicPath: '/',
  plugins: [
    manifestPlugin({
      generate: entries => (
        Object.entries(entries).reduce(
          (acc, [k, v]) => {
            const source = k.replace('priv/source/', '')
            const compiled = v.replace('build/', '/')
            acc[source] = compiled
            return acc
          },
          {}
        )
      )
    }),
    sassPlugin()
  ]
}

if (watch) {
  const ctx = await esbuild.context(config)
  await ctx.watch()
} else {
  await esbuild.build(config)
}
