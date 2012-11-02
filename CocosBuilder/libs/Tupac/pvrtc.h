/******************************************************************************

 @File         pvrtc.h

 @Title        

 @Version       @Version       * Notes        : Extracted from tools.c version 

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     ANSI

 @Description  header for pngrw.c  (AMTC related file)

******************************************************************************/
#ifndef PVRTCLIB_H
#define PVRTCLIB_H

#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************/
/*
// Function: 	pvrtc_compress
//
// Description:	Given raw, packed 32 bit ARGB data,
//				this routine generates the compress format as used by PowerVR MBX.
//
// Inputs:		InputArrayRGBA 	Input data as a packed array of bytes (8A 8R 8G 8B)
//
//				OutputMemory	Supplied memory for storage of resulting compress data.
// 								
//				nWidth			
//				nHeight			Texture dimensions: Power of 2 square textures currently 
//								supported. Sizes are limited to 8x8 through to 2048x2048, 
//                              16x8 through 2048x2048 for 2 bpp cases.
//				bMipMap			Generate all mipmap levels. Recommended for rendering speed & 
//								quality
//				bAlphaOn		Is alpha data supplied? If not, assumed Alpha == 0xFF
//
//				bAssumeTiles	The texture wrap around the edges.
//
//              bUse2bitFormat  2bit per pixel format. Otherwise 4bit per pixel format.
*/
/******************************************************************************/

int pvrtc_compress(	void*	InputArrayARGB,
					void*	OutputMemory,
					int		nWidth,			
					int		nHeight, 
					int		bMipMap,	    
					int		bAlphaOn,
					int		bAssumeTiles,
					int     bUse2bitFormat);

/******************************************************************************/
/*
// Function: 	 pvrtc_decompress
//
// Description: Given an array of pixels compressed using PVR tetxure compression
//              generates the row 32-bit ARGB (8A8R8G8B) array.
//
// Inputs:		
//				InputMemory		Supplied data of stored compressed pixels.
//
//				OutputArrayARGB Output data as a packed array of bytes (8R 8G 8B 8A)
//
//				nWidth			
//				nHeight			Texture dimensions: Power of 2 sizes currently 
//								supported, and these are limited to 8x8 through to 
//								2048x2048. 16x8 through 2048x2048 for 2 bpp cases.
//				nMipMapLevel	Level to be decompressed
//
//              bAssumeTiles	The texture wrap around the edges.
//
//              bUse2bitFormat  2bit per pixel format. Otherwise 4bit per pixel.
*/
/******************************************************************************/
int pvrtc_decompress(	void*	OutputArrayARGB,
						void*	InputMemory,
						int		nWidth,			
						int		nHeight, 		
						int     nMipmapLevel,
						int		nAssumeTiles,
						int     nCompressionMode);

/*************************************************************************
// The PVRTC file size.
// Use it for quering the final size after compression.
//				nWidth			Current testure width
//				nHeight			Current testure height
//				bMipMap			Mipmap is used
//				bUse2bitFormat  2bit per pixel format. Otherwise 4bit per pixel.
**************************************************************************/

int pvrtc_size(	int		nWidth,				
				int		nHeight, 		
				int		bMipMap,		
				int     bUse2bitFormat
				);

/******************************************************************************/
/*
// Function: 	pvrtc_getversion
//
// Description: Returns the version of PVRTC.
//
*/
/******************************************************************************/

void pvrtc_get_version(unsigned int *uMayor, unsigned int *uMinor, unsigned int *uInternal, unsigned int *uBuild);

/************************************************************************
// pvrtc_info_output. 
// default output = NULL (no output)
// Other values are stdout, stderr or a file created by the user
*************************************************************************/
void pvrtc_info_output(FILE *DebugOutput);


#ifdef __cplusplus
}
#endif

#endif /* PVRTCLIB_H */
/*
// END OF FILE
*/ 


