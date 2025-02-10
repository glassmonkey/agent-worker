const nextJest = require('next/jest')

const createJestConfig = nextJest({
  // next.config.jsとテスト環境用の.envファイルが配置されたディレクトリをセット
  dir: './',
})

// Jestのカスタム設定を設置する場所
const customJestConfig = {
  // テストファイルのパターンを指定
  testMatch: ['**/*.test.ts', '**/*.test.tsx'],
  // テスト環境を指定
  testEnvironment: 'jest-environment-jsdom',
  // テストの前に実行するセットアップファイル
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  // モジュール名のエイリアスを設定
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
}

// createJestConfigを定義して、それをモジュールとしてエクスポート
module.exports = createJestConfig(customJestConfig) 