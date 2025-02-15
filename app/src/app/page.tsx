'use client'

import styles from './page.module.css'

export default function Home() {
  return (
    <main className={styles.main}>
      <div className={styles.gameContainer}>
        <div className={styles.spaceship}></div>
        <h1 className={styles.gameTitle}>SPACE INVADERS</h1>
        <p className={styles.gameSubtitle}>No enemies here! Enjoy a peaceful space journey.</p>
      </div>
    </main>
  )
}
