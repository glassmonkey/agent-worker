import { render, screen, fireEvent } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import Home from './page'

describe('Home', () => {
  it('renders header with title', () => {
    render(<Home />)
    const header = screen.getByRole('heading', { name: /こんにちは/i })
    expect(header).toBeInTheDocument()
  })

  it('renders message input form', () => {
    render(<Home />)
    const textarea = screen.getByPlaceholderText("What's happening?")
    const submitButton = screen.getByRole('button', { name: /post/i })
    
    expect(textarea).toBeInTheDocument()
    expect(submitButton).toBeInTheDocument()
    expect(submitButton).toBeDisabled()
  })

  it('enables submit button when message is not empty', async () => {
    const user = userEvent.setup()
    render(<Home />)
    
    const textarea = screen.getByPlaceholderText("What's happening?")
    const submitButton = screen.getByRole('button', { name: /post/i })
    
    await user.type(textarea, 'Hello, World!')
    expect(submitButton).toBeEnabled()
  })

  it('posts a new message when form is submitted', async () => {
    const user = userEvent.setup()
    render(<Home />)
    
    const textarea = screen.getByPlaceholderText("What's happening?")
    const submitButton = screen.getByRole('button', { name: /post/i })
    
    await user.type(textarea, 'Hello, World!')
    await user.click(submitButton)
    
    const message = screen.getByText('Hello, World!')
    expect(message).toBeInTheDocument()
    expect(textarea).toHaveValue('')
  })

  it('should render counter with initial value of 0', () => {
    render(<Home />)
    expect(screen.getByText('Count: 0')).toBeInTheDocument()
  })

  it('should increment counter when increment button is clicked', () => {
    render(<Home />)
    const incrementButton = screen.getByText('Increment')
    fireEvent.click(incrementButton)
    expect(screen.getByText('Count: 1')).toBeInTheDocument()
  })

  it('should decrement counter when decrement button is clicked', () => {
    render(<Home />)
    const decrementButton = screen.getByText('Decrement')
    fireEvent.click(decrementButton)
    expect(screen.getByText('Count: -1')).toBeInTheDocument()
  })
}) 