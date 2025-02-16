'use client'

import { useEffect, useState } from 'react'
import styles from './page.module.css'

export default function Home() {
  const [playerPosition, setPlayerPosition] = useState(50) // 画面中央を初期位置とする
  const [bullets, setBullets] = useState<{ id: number; position: number; bottom: number }[]>([])
  const [isCooldown, setIsCooldown] = useState(false) // クールダウン状態を管理
  const moveSpeed = 5 // 移動速度
  const bulletSpeed = 5
  const shootCooldown = 250 // 発射間隔（ミリ秒）
  const COOLDOWN_TIME = 250 // クールダウン時間（ミリ秒）
  const GAME_HEIGHT = 100 // ゲーム領域の高さ（パーセント）
  const BULLET_SPEED = 5 // 弾の速度（ピクセル）

  // 発射音を再生する関数
  function playShootSound() {
    if (typeof window !== 'undefined') {
      const audio = new Audio('/shoot.mp3')
      audio.volume = 0.3 // 音量を30%に設定
      const playPromise = audio.play()
      if (playPromise !== undefined) {
        playPromise.catch(error => console.log('Audio playback failed:', error))
      }
    }
  }

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'ArrowLeft') {
        setPlayerPosition((prev) => Math.max(0, prev - moveSpeed))
      } else if (event.key === 'ArrowRight') {
        setPlayerPosition((prev) => Math.min(100, prev + moveSpeed))
      } else if (event.key === ' ' && !isCooldown) {
        playShootSound()
        const newBullet = {
          id: Date.now(),
          position: playerPosition,
          bottom: 60, // プレイヤーの高さに合わせて調整
        }
        setBullets(prev => [...prev, newBullet])
        setIsCooldown(true)
        setTimeout(() => {
          setIsCooldown(false)
        }, COOLDOWN_TIME)
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [playerPosition, isCooldown])

  useEffect(() => {
    const moveInterval = setInterval(() => {
      setBullets(prev => {
        const newBullets = prev.map(bullet => ({
          ...bullet,
          bottom: bullet.bottom + BULLET_SPEED,
        }))
        return newBullets.filter(bullet => bullet.bottom < GAME_HEIGHT)
      })
    }, 16) // 約60FPS

    return () => clearInterval(moveInterval)
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
          {bullets.map(bullet => (
            <div
              key={bullet.id}
              data-testid="bullet"
              className={styles.bullet}
              style={{
                left: `${bullet.position}%`,
                bottom: `${bullet.bottom}px`,
              }}
            />
          ))}
        </div>
      </div>
      <p className={styles.counter}>Press SPACE to shoot!</p>
    </main>
  )
}
