/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Poppins', 'sans-serif'],
      },
      colors: {
        primary: {
          50:  '#fff0f3',
          100: '#ffe4ea',
          200: '#ffc9d6',
          300: '#ff9db5',
          400: '#ff6690',
          500: '#ff3370',
          600: '#e91e63',
          700: '#c2185b',
          800: '#ad1457',
          900: '#880e4f',
        },
      },
      animation: {
        'slide-in': 'slide-in 0.2s ease-out forwards',
      },
      keyframes: {
        'slide-in': {
          from: { opacity: '0', transform: 'translateY(12px)' },
          to:   { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
  plugins: [],
};
