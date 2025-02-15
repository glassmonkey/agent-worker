'use client'

import styles from './page.module.css'

export default function Home() {
  return (
    <main className={styles.main}>
      <div className={styles.gameContainer}>
        <div className={styles.invader}>
          <div className={styles.invaderBody}>
            <div className={styles.invaderEye}></div>
            <div className={styles.invaderEye}></div>
          </div>
          <div className={styles.invaderLegs}>
            <div className={styles.leg}></div>
            <div className={styles.leg}></div>
            <div className={styles.leg}></div>
            <div className={styles.leg}></div>
          </div>
        </div>
        <h1 className={styles.gameTitle}>SPACE INVADERS</h1>
      </div>
    </main>
  )
}
