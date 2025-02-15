'use client'

import { useEffect, useState } from 'react'
import styles from './page.module.css'

export default function Home() {
  const [playerPosition, setPlayerPosition] = useState(50) // 画面中央を初期位置とする
  const [bullets, setBullets] = useState<{ id: number; x: number; y: number }[]>([])
  const [canShoot, setCanShoot] = useState(true) // 発射可能状態を管理
  const moveSpeed = 5 // 移動速度
  const bulletSpeed = 5
  const shootCooldown = 250 // 発射間隔（ミリ秒）
  let bulletId = 0

  // 発射音を再生する関数
  const playShootSound = () => {
    const audio = new Audio('/shoot.mp3')
    audio.volume = 0.3 // 音量を30%に設定
    audio.play().catch(error => console.log('Audio playback failed:', error))
  }

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'ArrowLeft') {
        setPlayerPosition((prev) => Math.max(0, prev - moveSpeed))
      } else if (event.key === 'ArrowRight') {
        setPlayerPosition((prev) => Math.min(100, prev + moveSpeed))
      } else if (event.key === ' ' && canShoot) {
        // 弾を発射（クールダウン中は発射不可）
        setCanShoot(false)
        playShootSound()
        setBullets(prev => [...prev, {
          id: bulletId++,
          x: playerPosition,
          y: 95 // プレイヤーの位置（画面下部から5%の位置）
        }])
        
        // クールダウン後に発射可能状態に戻す
        setTimeout(() => {
          setCanShoot(true)
        }, shootCooldown)
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [playerPosition, canShoot])

  // 弾の移動を制御
  useEffect(() => {
    const interval = setInterval(() => {
      setBullets(prev => {
        // 画面外に出た弾を削除し、残りの弾を上に移動
        return prev
          .filter(bullet => bullet.y > 0)
          .map(bullet => ({
            ...bullet,
            y: bullet.y - bulletSpeed // 上方向への移動（yの値を減少）
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
                top: `${bullet.y}%`
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
