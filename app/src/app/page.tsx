'use client'

import { useState } from 'react'
import styles from './page.module.css'

type Message = {
  id: string
  text: string
  username: string
  timestamp: Date
}

export default function Home() {
  const [messages, setMessages] = useState<Message[]>([])
  const [newMessage, setNewMessage] = useState('')
  const [count, setCount] = useState(0)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!newMessage.trim()) return

    const message: Message = {
      id: Math.random().toString(36).substring(7),
      text: newMessage.trim(),
      username: 'User',
      timestamp: new Date()
    }

    setMessages([message, ...messages])
    setNewMessage('')
  }

  const increment = () => {
    setCount(count + 1)
  }

  const decrement = () => {
    setCount(count - 1)
  }

  return (
    <main className={styles.main}>
      {/* Header */}
      <header className="sticky top-0 z-10 bg-black/80 backdrop-blur-sm border-b border-gray-700">
        <div className="max-w-2xl mx-auto px-4 py-3">
          <h1 className="text-xl font-bold text-white">こんにちは</h1>
        </div>
      </header>

      <div className={styles.counter}>
        <p>Count: {count}</p>
        <div className={styles.buttons}>
          <button onClick={increment}>Increment</button>
          <button onClick={decrement}>Decrement</button>
        </div>
      </div>

      {/* Message Input */}
      <div className="max-w-2xl mx-auto px-4 py-4 border-b border-gray-700">
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <textarea
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            placeholder="What's happening?"
            className="w-full bg-transparent text-white resize-none outline-none placeholder:text-gray-500"
            rows={3}
          />
          <div className="flex justify-end">
            <button
              type="submit"
              disabled={!newMessage.trim()}
              className="px-4 py-2 bg-blue-500 text-white font-bold rounded-full hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Post
            </button>
          </div>
        </form>
      </div>

      {/* Messages */}
      <div className="max-w-2xl mx-auto divide-y divide-gray-700">
        {messages.map(message => (
          <article key={message.id} className="px-4 py-3 hover:bg-gray-900/50 transition-colors">
            <div className="flex gap-3">
              <div className="flex-shrink-0">
                <div className="w-10 h-10 rounded-full bg-gray-700" />
              </div>
              <div className="flex-grow min-w-0">
                <div className="flex items-center gap-2">
                  <span className="font-bold text-white">{message.username}</span>
                  <span className="text-gray-500">·</span>
                  <time className="text-gray-500">
                    {message.timestamp.toLocaleTimeString()}
                  </time>
                </div>
                <p className="text-white whitespace-pre-wrap break-words">{message.text}</p>
                <div className="flex gap-16 mt-2">
                  <button className="text-gray-500 hover:text-blue-500 transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M12 20.25c4.97 0 9-3.694 9-8.25s-4.03-8.25-9-8.25S3 7.444 3 12c0 2.104.859 4.023 2.273 5.48.432.447.74 1.04.586 1.641a4.483 4.483 0 0 1-.923 1.785A5.969 5.969 0 0 0 6 21c1.282 0 2.47-.402 3.445-1.087.81.22 1.668.337 2.555.337Z" />
                    </svg>
                  </button>
                  <button className="text-gray-500 hover:text-green-500 transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 12c0-1.232-.046-2.453-.138-3.662a4.006 4.006 0 0 0-3.7-3.7 48.678 48.678 0 0 0-7.324 0 4.006 4.006 0 0 0-3.7 3.7c-.017.22-.032.441-.046.662M19.5 12l3-3m-3 3-3-3m-12 3c0 1.232.046 2.453.138 3.662a4.006 4.006 0 0 0 3.7 3.7 48.656 48.656 0 0 0 7.324 0 4.006 4.006 0 0 0 3.7-3.7c.017-.22.032-.441.046-.662M4.5 12l3 3m-3-3 3-3" />
                    </svg>
                  </button>
                  <button className="text-gray-500 hover:text-red-500 transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12Z" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </article>
        ))}
      </div>
    </main>
  )
}
