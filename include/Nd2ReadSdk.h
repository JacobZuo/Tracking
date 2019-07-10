#pragma once

#include <stdlib.h>

/*! \mainpage
   The Nd2ReadSdk is a set of C functions (and structures) declared in Nd2ReadSdk.h.

   Nd2ReadSdk is a thin wrapper around proprietary LimFile library. It uses pointers and JSON strings
   to pass out image data and metadata. Internally the SDK uses N. Lohmanns JSON
   library available at https://github.com/nlohmann/json.

   The SDK is available on Linux, MacOS and Windows. It consists of:
   - one header file (Nd2ReadSdk.h),
   - two dynamic libraries (libLimFile.so and libNd2ReadSdk.so for Linux,
   libLimFile.dylib and libNd2ReadSdk.dylib for MacOS and LimFile.dll and Nd2ReadSdk.dll for Windows),
   - two static libraries (libLimFile.a and libNd2ReadSdk.a for Linux and MacOS
   and LimFileStatic.lib and Nd2ReadSdkStatic.lib for Windows),
   - Nd2Info example as source and as built program both dynamic and static version and
   - documentation.

   When linking statically with Nd2ReadSdkStatic:
   - set the LX_STATIC_LINKING preprocessor definiton and
   - link to dynamic LimFile or
   - link to static LimFileStatic and provide static libs for zlib and libtiff

   ## Linux dependencies

   On Linux the SDK was built and tested on Debian version 8.4 and CentOS version 7.3.

   Here are the runtime dependencies of the Nd2Info and Nd2InfoStatic:
~~~~~
   $ ldd -d Nd2Info
	linux-vdso.so.1
	libNd2ReadSdk.so
	libLimFile.so
   libz.so.1
   libtiff.so.5
	libicuuc.so.50
	libicutu.so.50
	libstdc++.so.6
	libm.so.6
	libgcc_s.so.1
   libc.so.6
   libjbig.so.2.0
   libjpeg.so.62
   libicudata.so.50
	libpthread.so.0	
	libdl.so.2
	libicui18n.so.50
	/lib64/ld-linux-x86-64.so.2

   $ ldd -d Nd2InfoStatic
   linux-vdso.so.1
   libz.so.1
   libtiff.so.5
   libicuuc.so.50
   libicutu.so.50
   libstdc++.so.6
   libm.so.6
   libgcc_s.so.1
   libc.so.6
   libjbig.so.2.0
   libjpeg.so.62
   libicudata.so.50
   libpthread.so.0
   libdl.so.2
   libicui18n.so.50
   /lib64/ld-linux-x86-64.so.2
~~~~~

   The libicu*.so are part of the ICU package needed to handle unicide text.
   On Debian it can be installed using APT package manager (libicu52).

   ## MacOS dependencies

   On MacOS the SDK was built and tested on MacOS version 10.13.3.

   Here are the runtime dependencies of the Nd2Info and Nd2InfoStatic:
~~~~~
   $ otool -L Nd2Info
   Nd2Info:
   	@rpath/libNd2ReadSdk.dylib (compatibility version 0.0.0, current version 0.0.0)
   	@rpath/libLimFile.dylib (compatibility version 0.0.0, current version 0.0.0)
   	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 400.9.0)
   	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.0.0)

   $ otool -L Nd2InfoStatic
   Nd2InfoStatic:
   	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 400.9.0)
   	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.0.0)
~~~~~

   ## Windows dependencies

   On Windows the SDK was built with Microsoft Visual Studio 2015.

   - Nd2Info.exe requires Nd2ReadSdk.dll,  LimFile.dll, tiff.dll, zlib.dll, msvcp140.dll, vcruntime140.dll and kernel32.dll
   - Nd2InfoStatic.exe requires tiff.dll, zlib.dll, msvcp140.dll, vcruntime140.dll and kernel32.dll

   Visual C++ Redistributable for Visual Studio 2015 (msvcp140.dll and vcruntime140.dll)
   can be downloaded from [Microsoft](https://www.microsoft.com/en-US/download/details.aspx?id=48145).

   ## Nd2Info and Nd2InfoStatic example program

   The program outputs given metadata as JSON string representation to stdout.
   Following metadata can be retrieved:
   - attributes (see Lim_FileGetAttributes())
   - dimensions (see Lim_FileGetCoordSize() and Lim_FileGetCoordInfo())
   - coordinates (see Lim_FileGetSeqCount() and Lim_FileGetCoordsFromSeqIndex())
   - experiment (see Lim_FileGetExperiment())
   - metadata global or per frame if either coordinates or sequence index is
   provided (see Lim_FileGetMetadata())
   - textinfo (see Lim_FileGetTextinfo())

   All image data can be copied line after line and frame after frame into given file
   (see Lim_FileGetImageData()).

~~~~~
   Usage: Nd2Info.exe cmd [options] file.nd2
   cmd:
       allinfo <no options> - prints all metadata
       attributes <no options> - prints attributes
       coordinates <no options> - prints all frame coordinates
       dimensions <no options> - prints coordinate dimensions
       dumpallimages filename - makes superstack of all images
       experiment <no options> - prints experiment
       imageinfo <no options> - prints image size
       metadata <no options> - prints global metadata
       metadata seqIndex - prints global metadata merged with frame metadata
       metadata "[c0, c1, ...]" - prints global metadata merged with frame metadata
       textinfo <no options> - prints textinfo
~~~~~
*/

/*! \file Nd2ReadSdk.h

   \brief C Interface to access images and metadata stored in ND2 files.

   ND2 file contains image data, metadata and other assets.

   There are four metadata types that can be accessed using this SDK: attributes, experiment, metadata and textinfo.
   Metadata are return by the SDK as JSON string (the encoding is utf-8).

   Attributes Lim_FileGetAttributes() describe 2D image frames (width, height, frameCount, etc.) in the file.

   Experiment Lim_FileGetExperiment() describes dimensions (also referred to as acquisition loops) of the ND2 file and related information.
   There can be zero (single frame) or more dimensions (e.g. TimeLoop and ZStackLoop).

   Metadata Lim_FileGetMetadata and() Lim_FileGetFrameMetadata() describe global or per frame properties of the acquisition system.

   Image data are stored as 2D frames or images containing one or more color components (channels).
   Frames are accessed by Lim_FileGetImageData() and specifying frame sequential index.

   Sequential index can be conferted from and to coordinates (or logical loop indexes).
   It is useful to get 3rd Time index and 4th ZStack index [2, 3] (indexes are zero based).
*/

typedef char                     LIMCHAR;    //!< Multi-byte char for UTF-8 strings
typedef LIMCHAR*                 LIMSTR;     //!< Pointer to null-terminated multi-byte char array
typedef LIMCHAR const*           LIMCSTR;    //!< Pointer to null-terminated const multi-byte char array
typedef wchar_t                  LIMWCHAR;   //!< Wide-char (platform specific)
typedef LIMWCHAR*                LIMWSTR;    //!< Pointer to null-terminated wide-char array
typedef LIMWCHAR const*          LIMCWSTR;   //!< Pointer to null-terminated const wide-char array
typedef unsigned int             LIMUINT;    //!< Unsigned integer 32-bit
typedef unsigned long long       LIMUINT64;  //!< Unsigned integer 64-bit
typedef size_t                   LIMSIZE;    //!< Memory Size type
typedef int                      LIMINT;     //!< Integer 32-bit
typedef int                      LIMBOOL;    //!< Integer boolean value {0, 1}
typedef int                      LIMRESULT;  //!< Integer result codes

#define LIM_OK                    0
#define LIM_ERR_UNEXPECTED       -1
#define LIM_ERR_NOTIMPL          -2
#define LIM_ERR_OUTOFMEMORY      -3
#define LIM_ERR_INVALIDARG       -4
#define LIM_ERR_NOINTERFACE      -5
#define LIM_ERR_POINTER          -6
#define LIM_ERR_HANDLE           -7
#define LIM_ERR_ABORT            -8
#define LIM_ERR_FAIL             -9
#define LIM_ERR_ACCESSDENIED     -10
#define LIM_ERR_OS_FAIL          -11
#define LIM_ERR_NOTINITIALIZED   -12
#define LIM_ERR_NOTFOUND         -13
#define LIM_ERR_IMPL_FAILED      -14
#define LIM_ERR_DLG_CANCELED     -15
#define LIM_ERR_DB_PROC_FAILED   -16
#define LIM_ERR_OUTOFRANGE       -17
#define LIM_ERR_PRIVILEGES       -18
#define LIM_ERR_VERSION          -19
#define LIM_SUCCESS(res)         (0 <= (res))

/*!
   \brief Holds the picture and description
*/
struct _LIMPICTURE
{
   LIMUINT     uiWidth;             //!< Width (in pixels) of the picture
   LIMUINT     uiHeight;            //!< Height (in pixels) of the picture
   LIMUINT     uiBitsPerComp;       //!< Number of bits for each component
   LIMUINT     uiComponents;        //!< Number of components in each pixel
   LIMSIZE     uiWidthBytes;        //!< Number of bytes for each pixel line (stride); aligned to 4bytes
   LIMSIZE     uiSize;              //!< Number of bytes the image occupies
   void*       pImageData;          //!< Image data
};

typedef struct _LIMPICTURE LIMPICTURE; //!< Picture description and data pointer
typedef void*  LIMFILEHANDLE;          //!< Opaque type representing an opened ND2 file

#if defined(_WIN32) && defined(_DLL) && !defined(LX_STATIC_LINKING)
#  define DLLEXPORT __declspec(dllexport)
#  define DLLIMPORT __declspec(dllimport)
#else
#  define DLLEXPORT
#  define DLLIMPORT
#endif

#if defined(__cplusplus)
#  define EXTERN extern "C"
#else
#  define EXTERN extern
#endif

#if defined(GNR_ND2_SDK_EXPORTS)
#  define LIMFILEAPI EXTERN DLLEXPORT
#else
#  define LIMFILEAPI EXTERN DLLIMPORT
#endif

/*!
\brief Opens an ND2 file for reading. This is widechar version.
\param[in] wszFileName The filename (system wide-char) to be used.

Returns \c nullptr if the file does not exist or cannot be opened for read or is corrupted.
On succes returns (non-null) \c LIMFILEHANDLE which must be closed with \c Lim_FileClose to deallocate resources.
\sa Lim_FileClose(), Lim_FileOpenForReadUtf8(LIMCSTR szFileNameUtf8)
*/
LIMFILEAPI LIMFILEHANDLE   Lim_FileOpenForRead(LIMCWSTR wszFileName);

/*!
\brief Opens an ND2 file for reading. This is multi-byte version (the encoding is utf-8).
\param[in] szFileNameUtf8 The filename (multi-byte utf8 encoding) to be used.

Returns \c nullptr if the file does not exist or cannot be opened for read or is corrupted.
On succes returns (non-null) \c LIMFILEHANDLE which must be closed with \c Lim_FileClose to deallocate resources.
\sa Lim_FileClose(), Lim_FileOpenForRead(LIMCWSTR wszFilename)
*/
LIMFILEAPI LIMFILEHANDLE   Lim_FileOpenForReadUtf8(LIMCSTR szFileNameUtf8);

/*!
\brief Closes a file previously opened by this SDK.
\param[in] hFile The handle to an opened file.

If \a hFile is nullptr the function des nothing.

\sa Lim_FileOpenForReadUtf8(LIMCSTR szFileNameUtf8), Lim_FileOpenForRead(LIMCWSTR wszFilename)
*/
LIMFILEAPI void            Lim_FileClose(LIMFILEHANDLE hFile);

/*!

\brief Returs the dimensionality of the file or the number items in loop coordiante.
\param[in] hFile The handle to an opened file.

Zero means the file contains only one frame (not an ND document).
*/
LIMFILEAPI LIMSIZE         Lim_FileGetCoordSize(LIMFILEHANDLE hFile);

/*!
\brief Returs size of the \a coord dimension.
\param[in] hFile The handle to an opened file.
\param[in] coord The index of the coordinate.
\param[out] type Pointer to string buffer which receives the type.
\param[in] maxTypeSize Maximum number of chars the buffer can hold.

Coord must be lower than \c Lim_FileGetCoordSize().
If \a type is not nullptr it is filled by the name of the loop type: "Unknown", "TimeLoop", "XYPosLoop", "ZStackLoop", "NETimeLoop".
*/
LIMFILEAPI LIMUINT         Lim_FileGetCoordInfo(LIMFILEHANDLE hFile, LIMUINT coord, LIMSTR type, LIMSIZE maxTypeSize);

/*!
\brief Returs the number of frames.
\param[in] hFile The handle to an opened file.
*/
LIMFILEAPI LIMUINT         Lim_FileGetSeqCount(LIMFILEHANDLE hFile);

/*!
\brief Converts coordinates into sequence index.
\param[in] hFile The handle to an opened file.
\param[in] coords The array of logical coordinates.
\param[in] coordCount The number of logical coordinates.
\param[out] seqIdx The pointer that is filled with corresponding sequence index.

If wrong argument is passed or the coordinate is not present in the file the function fails and returns 0.
On success it returns nonzero value.
*/
LIMFILEAPI LIMBOOL         Lim_FileGetSeqIndexFromCoords(LIMFILEHANDLE hFile, const LIMUINT * coords, LIMSIZE coordCount, LIMUINT* seqIdx);

/*!
\brief Converts sequence index into coordinates.
\param[in] hFile The handle to an opened file.
\param[in] seqIdx The sequence index.
\param[out] coords The array that is fileld with logical coordinates.
\param[in] maxCoordCount The maximum nuber of coordinates the array can hold.

On success it returns the number of coordinate dimensions.
If coords is nullptr the function only returns the dimension of coordinate required to store the result.
*/
LIMFILEAPI LIMSIZE         Lim_FileGetCoordsFromSeqIndex(LIMFILEHANDLE hFile, LIMUINT seqIdx, LIMUINT* coords, LIMSIZE maxCoordCount);

/*!
\brief Returns attributes as JSON (object) string.
\param[in] hFile The handle to an opened file.

Attributes are always present in the file and contain following members:

member                      | type               | description
--------------------------- | ------------------ | ---------------
bitsPerComponentInMemory    | number             | bits allocated to hold each component
bitsPerComponentSignificant | number             | bits effectively used by each component (not used bits must be zero)
componentCount              | number             | number of compoents in a pixel
compressionLevel            | number, optional   | if comperssion is used the level of compression
compressionType             | string, optional   | type of compression: "lossless" or "lossy"
heightPx                    | number             | height of the image
pixelDataType               | string             | undrlying data type "unsigned" or "float"
sequenceCount               | number             | number of image frames in the file
tileHeightPx                | number, optional   | suggested tile height if saved as tiled
tileWidthPx                 | number, optional   | suggested tile width if saved as tiled
widthBytes                  | number             | number of bytes from the beginning of one line to the next one
widthPx                     | number             | width of the image

The memory size for image buffer is calculated as widthBytes * heightPx.

Returned string must be deleted using Lim_FileFreeString().

\sa Lim_FileFreeString()
*/
LIMFILEAPI LIMSTR          Lim_FileGetAttributes(LIMFILEHANDLE hFile);

/*!
\brief Returns metadata as JSON (object) string.
\param[in] hFile The handle to an opened file.

Presence of the metadata in the file as well as any field is optional.

Metadata is broken per channel as it is the highest (most global)
asset in the file. It contains only information which do not change per
frame.

These ate the metadata structures:

structure    | where / different | description
------------ | ----------------- | ------------
contents     | root (global)     | assets in the file (e.g. number of frames and channels)
channels     | root (global)     | array of channels
channel      | per channel       | channel related info (e.g. name, color)
loops        | per channel       | loopname to loopindex map
microscope   | per channel       | relevant microscope settings (magnifications)
volume       | per channel       | image data valume related information

_contents_ list number of assets:
- channelCount determines the number of channels across all frames and
- frameCount determines the number of frames in the file.

_channels_ contais the array of channels where each contains:
- channel
- loops
- microscope
- volume

_channel_ contains:
- name of the channel,
- index of the channel which uniquely identifies the channel in the file and
- colorRGB definig the RGB color to show the channel in.

_loops_ contains mapping from loop name into loopindex

_microscope_ contains instrument related info:
- objectiveName
- objectiveMagnification
- objectiveNumericalAperture
- projectiveMagnification
- zoomMagnification
- immersionRefractiveIndex
- pinholeDiameterUm

_volume_ contains:
- axesCalibrated contains 3 bools (XYZ) indicating which axes are calibrated
- axesCalibration contains 3 doubles (XYZ) with calibration
- axesInterpretation contains 3 strings (XYZ) defining the physical interpretation:
   - distance (default) axis is in microns (um) and calibration is in um/px
   - time axis is in milliseconds (ms) and calibration is in ms/px
- bitsPerComponentInMemory
- bitsPerComponentSignificant
- componentCount
- componentDataType is either unsigned or float
- voxelCount contains 3 integers (XYZ) indicating the number of voxels in each direction
- cameraTransformationMatrix a 2x2 matrix mapping camera space (origin is the image center, X going right, Y down) to normalized stage space (X going left, Y going up). It does not convert between pixels and um.
- pixelToStageTransformationMatrix a 2x3 matrix which transforms pixel coordinates (origin is the image top-left corner) to the actual device coordinates in um. It does not add the image position to the coordinates.

NIS Microscope Absolute frame in um = pixelToStageTransformationMatrix * (X_in_px  Y_in_px  1) + stagePositionUm

Returned string must be deleted using Lim_FileFreeString().

\sa Lim_FileFreeString()
*/
LIMFILEAPI LIMSTR          Lim_FileGetMetadata(LIMFILEHANDLE hFile);

/*!
\brief Returns frame metadata as JSON (object) string.
\param[in] hFile The handle to an opened file.
\param[in] uiSeqIndex The frame sequence index.

Presence of the metadata in the file as well as any field is optional.

By default (when metadataPointer is empty) the function returns all metadata
updated with the current per-frame info.

structure    | where / different       | description
------------ | ----------------------- | ------------
position     | per frame and channel   | frame postion
time         | per frame and channel   | frame time

_position_ holds position of the frame
- stagePositionUm contains 3 numbers (XYZ) indicating absolute position

_time_ holds information anout the frame time
- relativeTimeMs relative time (to the beginnig of the experiment) of the frame
- absoluteJulianDayNumber absolute time of the frame (see https://en.wikipedia.org/wiki/Julian_day)
- timerSourceHardware (if present) indicates the hardware used to capture the time (otherwise it is the software)

In many cases it may be inefficient to retrieve all the data. In order to get only
the data that change use the metadata pointer. E.g. in order to get only the time for the
first channel call the function with `"/channels/0/time"`.

Returned string must be deleted using Lim_FileFreeString().

\sa Lim_FileFreeString()
*/
LIMFILEAPI LIMSTR          Lim_FileGetFrameMetadata(LIMFILEHANDLE hFile, LIMUINT uiSeqIndex);

/*!
\brief Returns textinfo as JSON (object) string.
\param[in] hFile The handle to an opened file.

Presence of the textinfo in the file as well as any field is optional.

Following fielads are available:
- imageId
- type
- group
- sampleId
- author
- description
- capturing
- sampling
- location
- date
- conclusion
- info1
- info2
- optics

Returned string must be deleted using Lim_FileFreeString().

\sa Lim_FileFreeString()
*/
LIMFILEAPI LIMSTR          Lim_FileGetTextinfo(LIMFILEHANDLE hFile);

/*!
\brief Returns experiment as JSON (array) string.
\param hFile The handle to an opened file.

Presence of the experiment in the file as well as any field is optional.

Experiment is an array of loop objects. Each loop object contains info about the loop.
Each loop object contains:
- type definig the loop type (either "TimeLoop", "XYPosLoop", "ZStackLoop", "NETimeLoop"),
- count defining the number of iterations in the loop,
- nestingLevel defining the loop level and
- parameters describing the relevant experiment parameters.

_TimeLoop_ contains following items in parameters:
- startMs defining requested start of the sequence,
- periodMs definig requested period,
- durationMs defining requested duration and
- periodDiff which contains frame-to-frane statistics (average, maximum and minimum).

_NETimeLoop_ contains following items in parameters:
- periods which is a array of period information where each item contains:
   - count with the number of frames and
   - startMs, periodMs, durationMs and periodDiff as in TimeLoop

_XYPosLoop_ contains following items in parameters:
- isSettingZ defines if th Z position was set when visiting each point (otherwise only XY was set) and
- points which is an array of objects containing following members:
   - stagePositionUm definig the position of the point,
   - pfsOffset defining the pfs offset and
   - name (optionally) contains the name of the point.

_ZStackLoop_ contains following items in parameters:
- homeIndex defines which index is home position,
- stepUm defines the distance between slices
- bottomToTop defines the acquisition direction
- deviceName (optionally) contains the name of the device used to acquire the zStack.

Returned string must be deleted using Lim_FileFreeString().

\sa Lim_FileFreeString()
*/
LIMFILEAPI LIMSTR          Lim_FileGetExperiment(LIMFILEHANDLE hFile);

/*!
\brief Fills the \a pPicture with the frame indicated by the \a uiSeqIndex from the file.
\param hFile The handle to an opened file.
\param uiSeqIndex The the sequence index of the frame.
\param pPicture The pointer to `LIMPICTURE` structure that is filled with picture data.

If the \a pPicture is nullptr the function fails.

If the \c LIMPICTURE::pImageData and \c LIMPICTURE::uiSize members are zero the \c LIMPICTURE is properly initialized using to \c Lim_InitPicture.

If the \a pPicture is already initialized but the size doesnt match the function fails.

The \a pPicture must be deleted using Lim_DestroyPicture().

\sa Lim_InitPicture(), Lim_DestroyPicture()
*/
LIMFILEAPI LIMRESULT       Lim_FileGetImageData(LIMFILEHANDLE hFile, LIMUINT uiSeqIndex, LIMPICTURE* pPicture);

/*!
\brief Deallocates the string returned by metadata retrieving SDK function.
\param str The pointer to the string to be deallocated.

\sa Lim_FileGetAttributes(), Lim_FileGetExperiment(), Lim_FileGetMetadata(), Lim_FileGetFrameMetadata(), Lim_FileGetTextinfo()
*/
LIMFILEAPI void            Lim_FileFreeString(LIMSTR str);

/*!
\brief Initializes and allocates \a pPicture buffer to hold the image with given parameters.
\param pPicture The pointer `LIMPICTURE` structure to be initialized.
\param width The width (in pixels) of the picture.
\param height The height (in pixels) of the picture.
\param bpc The number of bits per each component (integer: 8-16 and floating: 32).
\param components The number of components in each pixel.

The parameters \a width, \a height \a bpc (bits per component) and \a components (number of color components in each pixel) are taken from attributes (Lim_FileGetAttributes()).

\sa Lim_DestroyPicture()
*/
LIMFILEAPI LIMSIZE         Lim_InitPicture(LIMPICTURE* pPicture, LIMUINT width, LIMUINT height, LIMUINT bpc, LIMUINT components);

/*!
\brief Deallocates resources allocated by \c Lim_InitPicture().
\param pPicture The pointer `LIMPICTURE` structure to be deallocated.

\sa Lim_InitPicture()
*/
LIMFILEAPI void            Lim_DestroyPicture(LIMPICTURE* pPicture);
