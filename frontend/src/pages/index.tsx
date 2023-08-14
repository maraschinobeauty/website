import { FunctionComponent, Fragment } from 'react'

import Head from 'next/head'

import styles from './styles.module.css'

const Index: FunctionComponent = () => (
    <Fragment>
        <Head>
            <title>
                Maraschino Beauty
            </title>
        </Head>

        <div className={styles.my_class}>
            Hello, world!
        </div>
    </Fragment>
)

export default Index
