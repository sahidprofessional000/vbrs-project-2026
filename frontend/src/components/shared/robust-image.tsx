'use client';

import React, { useState } from 'react';

interface RobustImageProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  src: string;
  fallbackSrc?: string;
  alt: string;
}

export function RobustImage({
  src,
  fallbackSrc,
  alt,
  className = '',
  ...props
}: RobustImageProps) {
  const [imgSrc, setImgSrc] = useState<string>(src);
  const [hasError, setHasError] = useState<boolean>(false);

  const handleError = () => {
    if (fallbackSrc && imgSrc !== fallbackSrc) {
      setImgSrc(fallbackSrc);
    } else {
      setHasError(true);
    }
  };

  if (hasError) {
    return (
      <div className={`bg-graphite border border-divider flex flex-col items-center justify-center p-6 text-center ${className}`}>
        <div className="w-8 h-8 rounded-full border border-divider flex items-center justify-center text-stone-dim mb-2 font-mono text-xs">
          //
        </div>
        <span className="font-mono text-[10px] uppercase tracking-wider text-stone-dim">
          {alt || 'ARCHIVE ASSET UNAVAILABLE'}
        </span>
      </div>
    );
  }

  return (
    <img
      src={imgSrc}
      alt={alt}
      onError={handleError}
      className={className}
      {...props}
    />
  );
}
