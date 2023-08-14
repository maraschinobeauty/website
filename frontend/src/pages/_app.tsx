import { FunctionComponent, Fragment } from 'react'
import { AppProps } from 'next/app'

import './globals.css'

const App: FunctionComponent<AppProps> = ({ Component, pageProps }) => (
    <Fragment>
        {/* <Navbar /> */}
        <Component {...pageProps} />
        {/* <Menu /> */}
    </Fragment>
)

export default App
