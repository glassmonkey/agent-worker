import { render, screen, fireEvent, act } from '@testing-library/react'
import Home from './page'
import '@testing-library/jest-dom'

jest.useFakeTimers()

describe('Home', () => {
  beforeEach(() => {
    jest.useFakeTimers()
  })

  afterEach(() => {
    jest.useRealTimers()
  })

  it('renders Welcome message', () => {
    render(<Home />)
    const message = screen.getByText(/Press SPACE to shoot!/i)
    expect(message).toBeInTheDocument()
  })

  it('renders the game title', () => {
    const { getByText } = render(<Home />)
    expect(getByText('SPACE INVADERS')).toBeInTheDocument()
  })

  it('renders the player', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player')
    expect(player).toBeInTheDocument()
  })

  it('moves player left when left arrow key is pressed', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player') as HTMLElement
    const initialLeft = player.style.left

    fireEvent.keyDown(window, { key: 'ArrowLeft' })
    
    expect(player.style.left).not.toBe(initialLeft)
    expect(parseFloat(player.style.left)).toBeLessThan(parseFloat(initialLeft))
  })

  it('moves player right when right arrow key is pressed', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player') as HTMLElement
    const initialLeft = player.style.left

    fireEvent.keyDown(window, { key: 'ArrowRight' })
    
    expect(player.style.left).not.toBe(initialLeft)
    expect(parseFloat(player.style.left)).toBeGreaterThan(parseFloat(initialLeft))
  })

  it('does not move player beyond left boundary', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player') as HTMLElement

    // Move left multiple times to hit boundary
    for (let i = 0; i < 20; i++) {
      fireEvent.keyDown(window, { key: 'ArrowLeft' })
    }
    
    expect(parseFloat(player.style.left)).toBe(0)
  })

  it('does not move player beyond right boundary', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player') as HTMLElement

    // Move right multiple times to hit boundary
    for (let i = 0; i < 20; i++) {
      fireEvent.keyDown(window, { key: 'ArrowRight' })
    }
    
    expect(parseFloat(player.style.left)).toBe(100)
  })

  it('creates a bullet when space key is pressed', () => {
    render(<Home />)
    
    // 初期状態では弾がないことを確認
    expect(screen.queryAllByTestId('bullet')).toHaveLength(0)
    
    // スペースキーを押して弾を発射
    fireEvent.keyDown(window, { key: ' ' })
    
    // 弾が作成されたことを確認
    expect(screen.queryAllByTestId('bullet')).toHaveLength(1)
  })

  it('respects shooting cooldown', () => {
    render(<Home />)
    
    // 1発目を発射
    act(() => {
      fireEvent.keyDown(window, { key: ' ' })
    })
    expect(screen.queryAllByTestId('bullet')).toHaveLength(1)
    
    // クールダウン中に発射を試みる
    act(() => {
      fireEvent.keyDown(window, { key: ' ' })
    })
    expect(screen.queryAllByTestId('bullet')).toHaveLength(1) // クールダウン中は新しい弾が作られない
    
    // クールダウン時間を待つ
    act(() => {
      jest.advanceTimersByTime(250)
    })
    
    // クールダウン後に発射
    act(() => {
      fireEvent.keyDown(window, { key: ' ' })
    })
    expect(screen.queryAllByTestId('bullet')).toHaveLength(2)
  })

  it('moves bullets upward and removes them when they leave the screen', () => {
    render(<Home />)
    
    // 弾を発射
    fireEvent.keyDown(window, { key: ' ' })
    
    // 弾の初期位置を確認
    const initialBullet = screen.getByTestId('bullet')
    const initialBottom = parseInt(initialBullet.style.bottom)
    
    // 時間を進める
    act(() => {
      jest.advanceTimersByTime(50)
    })
    
    // 弾が上に移動したことを確認
    const movedBullet = screen.getByTestId('bullet')
    const movedBottom = parseInt(movedBullet.style.bottom)
    expect(movedBottom).toBeGreaterThan(initialBottom)
    
    // 弾が画面外に出るまで時間を進める
    act(() => {
      jest.advanceTimersByTime(2000)
    })
    
    // 弾が削除されたことを確認
    expect(screen.queryAllByTestId('bullet')).toHaveLength(0)
  })
}) 