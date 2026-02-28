import { Link } from 'react-router-dom';
import { Sparkles, Shirt, Wand2 } from 'lucide-react';
import { Button } from '@/components/common/Button';

export const HomePage = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 via-purple-50 to-pink-50">
      {/* Hero Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <div className="text-center">
          <h1 className="text-5xl md:text-6xl font-bold text-gray-900 mb-6">
            Your AI-Powered
            <span className="text-primary-600"> Fashion Assistant</span>
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
            Build your digital wardrobe, get personalized outfit recommendations,
            and try on clothes virtually with cutting-edge AI technology.
          </p>
          <div className="flex gap-4 justify-center">
            <Link to="/register">
              <Button size="lg">
                Get Started Free
              </Button>
            </Link>
            <Link to="/login">
              <Button size="lg" variant="outline">
                Sign In
              </Button>
            </Link>
          </div>
        </div>
        
        {/* Features */}
        <div className="grid md:grid-cols-3 gap-8 mt-20">
          <div className="bg-white rounded-xl p-8 shadow-lg">
            <div className="w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center mb-4">
              <Shirt className="h-6 w-6 text-primary-600" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Digital Wardrobe
            </h3>
            <p className="text-gray-600">
              Upload and organize your clothing items with AI-powered categorization
              and color analysis.
            </p>
          </div>
          
          <div className="bg-white rounded-xl p-8 shadow-lg">
            <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mb-4">
              <Sparkles className="h-6 w-6 text-purple-600" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Smart Recommendations
            </h3>
            <p className="text-gray-600">
              Get daily outfit suggestions based on color harmony, style rules,
              and AI compatibility scoring.
            </p>
          </div>
          
          <div className="bg-white rounded-xl p-8 shadow-lg">
            <div className="w-12 h-12 bg-pink-100 rounded-lg flex items-center justify-center mb-4">
              <Wand2 className="h-6 w-6 text-pink-600" />
            </div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Virtual Try-On
            </h3>
            <p className="text-gray-600">
              See how clothes look on you before wearing them with our advanced
              virtual try-on technology.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
