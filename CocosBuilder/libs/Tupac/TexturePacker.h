#ifndef TEXTURE_PACKER_H

#define TEXTURE_PACKER_H

/*!
**
** Copyright (c) 2009 by John W. Ratcliff mailto:jratcliffscarab@gmail.com
**
** The MIT license:
**
** Permission is hereby granted, free of charge, to any person obtaining a copy
** of this software and associated documentation files (the "Software"), to deal
** in the Software without restriction, including without limitation the rights
** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the Software is furnished
** to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in all
** copies or substantial portions of the Software.

** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
** WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
** CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


// This code snippet will efficiently pack a collection of rectangles into a single larger enclosing rectangle.
// Typically used for packing many textures into a single texture.
//

// Here is how you use it.

// First create an instance of the TexturePacker interface.

// TEXTURE_PACKER::TexturePacker *tp = TEXTURE_PACKER::createTexturePacker();
//
// Next inform the system how many textures you want to pack.
//
// tp->setTextureCount(10);
//
// Now, add each texture's width and height in sequence 1-10
//
//  tp->addTexture(wid,hit)
//
// Next you pack them .
//
// int unused_area = tp->packTextures(width,height,true,true)
//
// The return code is the unused surface area.  It also returns the width and height of the rectangle needed to contain all textures.
// If you want to force your output texture to be a power of two, set that option to true.
// If you want a one pixel border around your textures set that parameter to true.
//
// Finally, to retrieve the results, for each texture 0-(n-1) call 'getTextureLocation'.
//
// This will return the x,y position of the texture in the texture atlas, and the width and height (should be the same as the original)
// Now, this is very important, if the getTextureLocation returns true, it means that the texture was rotated 90 degrees to make it
// better fit into the available space.  You should rotate your U/V co-ordinates accordingly.
//
// The algorithm for packing textures as as follows:
//
// Step #1 : Find the longest edge and total area of all source textures.
// Step #2 : Create a single large rectangle big enough to fit all textures; round up to the nearest power of two if necessary.
// Step #3 : Place each texture, first by finding the texture with the largest area and longest edge that has not yet been placed.
// Step #4 :  .. Look through the free nodes list and if a free node is exactly the same size, then use it.
//               Otherwise, find a free node that is furthest down and to the left of the co-ordinate space (growing up and too the right)
//               Always insert the node so that the long edge lays down, preventing as much as possible the texture-atlas from growing vertically.
//               If a placed node has been rotated 90 degrees (width/height swapped) flag it as so.
// Step #5 : If the texture we are inserting shares an edge with the free node, then simply shrink the free node down to make up the difference.
// Step #6 : If the texture doesn't share any edge then split the rectangle in two, allocating a new free node and adding to the node list.
// Step #7 : See if any nodes can be combined back into one; do this until no more rectangles can be collapsed.
// Step #8 : Repeat until all textures have been inserted.
// Step #9 : Find the maximum height we ended up using and return that as the actual height.  Clamp the height to the nearest power of two if needed.
// Step #10 : Iterate through the results and copy your textures to a single large texture-atlas.
//              This code does not do the image copying, that is done by your own application.

namespace TEXTURE_PACKER {
    class TexturePacker
    {
    public:
        virtual ~TexturePacker();
        virtual int   getTextureCount(void) = 0;
        virtual void  setTextureCount(int tcount) = 0; // number of textures to consider..
        virtual void  addTexture(int wid,int hit) = 0; // add textures 0 - n
        
        virtual bool  wouldTextureFit(int wid, int hit,
                                      bool forcePowerOfTwo,bool onePixelBorder,
                                      int max_wid, int max_hit) = 0;
        
        virtual int packTextures(int &width,int &height,bool forcePowerOfTwo,bool onePixelBorder) = 0;  // pack the textures, the return code is the amount of wasted/unused area.
        
        virtual bool  getTextureLocation(int index,int &x,int &y,int &wid,int &hit) = 0; // returns true if the texture has been rotated 90 degrees
        
    };
    
    
    TexturePacker * createTexturePacker(void);
    void            releaseTexturePacker(TexturePacker *tp);

}

#endif
