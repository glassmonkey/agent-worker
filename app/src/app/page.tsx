'use client'

import { useEffect, useState } from 'react'
import styles from './page.module.css'

export default function Home() {
  const [playerPosition, setPlayerPosition] = useState(50) // 画面中央を初期位置とする
  const [bullets, setBullets] = useState<{ id: number; x: number; y: number }[]>([])
  const moveSpeed = 5 // 移動速度
  const bulletSpeed = 5
  let bulletId = 0

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'ArrowLeft') {
        setPlayerPosition((prev) => Math.max(0, prev - moveSpeed))
      } else if (event.key === 'ArrowRight') {
        setPlayerPosition((prev) => Math.min(100, prev + moveSpeed))
      } else if (event.key === ' ') {
        // 弾を発射
        setBullets(prev => [...prev, {
          id: bulletId++,
          x: playerPosition,
          y: 90 // プレイヤーの位置から少し上
        }])
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [playerPosition])

  // 弾の移動を制御
  useEffect(() => {
    const interval = setInterval(() => {
      setBullets(prev => {
        // 画面外に出た弾を削除し、残りの弾を上に移動
        return prev
          .filter(bullet => bullet.y > 0)
          .map(bullet => ({
            ...bullet,
            y: bullet.y - bulletSpeed
          }))
      })
    }, 50)

    return () => clearInterval(interval)
  }, [])

  return (
    <main className={styles.main}>
      <div className={styles.gameContainer}>
        <h1 className={styles.gameTitle}>SPACE INVADERS</h1>
        <div className={styles.gameArea}>
          {bullets.map(bullet => (
            <div
              key={bullet.id}
              data-testid="bullet"
              className={styles.bullet}
              style={{
                left: `${bullet.x}%`,
                bottom: `${bullet.y}%`
              }}
            />
          ))}
          <div 
            className={styles.player}
            style={{ left: `${playerPosition}%` }}
          />
        </div>
      </div>
      <p className={styles.counter}>Press SPACE to shoot!</p>
    </main>
  )
}
