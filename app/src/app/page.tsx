'use client'

import styles from './page.module.css'

export default function Home() {
  return (
    <main className={styles.main}>
      <div className={styles.gameContainer}>
        <h1 className={styles.gameTitle}>SPACE INVADERS</h1>
      </div>
      <p className={styles.counter}>Welcome to the Invader Game! No enemies here, just enjoy the view.</p>
    </main>
  )
}
