'use client'

import { useEffect, useState } from 'react'
import styles from './page.module.css'

export default function Home() {
  const [playerPosition, setPlayerPosition] = useState(50) // 画面中央を初期位置とする
  const moveSpeed = 5 // 移動速度

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'ArrowLeft') {
        setPlayerPosition((prev) => Math.max(0, prev - moveSpeed))
      } else if (event.key === 'ArrowRight') {
        setPlayerPosition((prev) => Math.min(100, prev + moveSpeed))
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [])

  return (
    <main className={styles.main}>
      <div className={styles.gameContainer}>
        <h1 className={styles.gameTitle}>SPACE INVADERS</h1>
        <div className={styles.gameArea}>
          <div 
            className={styles.player}
            style={{ left: `${playerPosition}%` }}
          />
        </div>
      </div>
      <p className={styles.counter}>Welcome to the Invader Game! No enemies here, just enjoy the view.</p>
    </main>
  )
}
