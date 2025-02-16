import { render, screen, fireEvent, act } from '@testing-library/react'
import Home from './page'
import '@testing-library/jest-dom'

// Audio APIのモック
const mockPlay = jest.fn()
beforeAll(() => {
  window.HTMLMediaElement.prototype.play = mockPlay
})

describe('Home', () => {
  beforeEach(() => {
    jest.useFakeTimers()
    mockPlay.mockClear()
  })

  afterEach(() => {
    jest.useRealTimers()
  })

  it('renders game title', () => {
    render(<Home />)
    const title = screen.getByText('SPACE INVADERS')
    expect(title).toBeInTheDocument()
  })

  it('renders shoot instruction', () => {
    render(<Home />)
    const instruction = screen.getByText('Press SPACE to shoot!')
    expect(instruction).toBeInTheDocument()
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

  it('moves bullets upward and removes them when they leave the screen', () => {
    render(<Home />)
    
    // 弾を発射
    fireEvent.keyDown(window, { key: ' ' })
    
    // 弾の初期位置を確認
    const initialBullet = screen.getByTestId('bullet')
    const initialBottom = parseInt(initialBullet.style.bottom)
    
    // 時間を進める
    act(() => {
      jest.advanceTimersByTime(16)
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