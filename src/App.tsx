import { RouterProvider } from 'react-router-dom';
import { ThemeProvider } from './app/providers/theme-provider';
import { AuthProvider } from './app/providers/auth-provider';
import { router } from './app/router';

function App() {
  return (
    <ThemeProvider defaultTheme="light" storageKey="hr-platform-theme">
      <AuthProvider>
        <RouterProvider router={router} />
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
