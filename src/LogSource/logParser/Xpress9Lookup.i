/*

Parameters:
    TAIL_T          -- type of "tail" comperand (2 bytes if looking for 3-length match, may be 4 bytes if looking for longer match)
    pData           -- const UIn8 * pointer to the buffer containing original data
    uPosition       -- offset in original buffer to the beginning of uncompressed data
    uDataSize       -- number of bytes in original data bfufer
    pNext           -- array of references to the next substring beginning of which hashes to the same value
    uMaxDepth       -- max lookup depth
    DEEP_SEARCH     -- if uMaxDepth == 1 then it's better to set DEEP_SEARCH to 0, otherwise it should be 1
    uBestLength     -- length of longest match found so far
    iBestOffset     -- offset to the beginning of the longest match found so far

*/


do {
    const UInt8    *_pCompare;
    uxint           _uCandidate;
#if DEEP_LOOKUP
    uxint           _uMaxDepth = (uMaxDepth);
#endif /* DEEP_LOOKUP */

     xint           _iOffset;
    _uCandidate = pNext[uPosition];
    pNext[0]    = (UInt32) uPosition; // Important to note that 0 means a NULL pointer i.e. the end of the hash chain.

    for (;;)
    {
        uxint           _uCandidate2;
        {
            TAIL_T          _uTailComperand;

            _pCompare       = pData + uBestLength - (sizeof (TAIL_T) - 1);
            _uTailComperand = * (TAIL_T *) (_pCompare + uPosition);

            for (;;)
            {
#if DEEP_LOOKUP
                if (_uMaxDepth == 0)
                    goto L_Done;
                --_uMaxDepth;
#endif /* DEEP_LOOKUP */

                // Any hash chain is such that the indexes are in decreasing order.

                _uCandidate2 = pNext[_uCandidate];
                if (* (const TAIL_T *) (_pCompare + _uCandidate) == _uTailComperand)
                    goto L_Same1;

                _uCandidate = pNext[_uCandidate2];
                if (* (const TAIL_T *) (_pCompare + _uCandidate2) == _uTailComperand)
                    goto L_Same2;

                _uCandidate2 = pNext[_uCandidate];
                if (* (const TAIL_T *) (_pCompare + _uCandidate) == _uTailComperand)
                    goto L_Same1;

                _uCandidate = pNext[_uCandidate2];
                if (* (const TAIL_T *) (_pCompare + _uCandidate2) == _uTailComperand)
                    goto L_Same2;

                _uCandidate2 = pNext[_uCandidate];
                if (* (const TAIL_T *) (_pCompare + _uCandidate) == _uTailComperand)
                    goto L_Same1;

                _uCandidate = pNext[_uCandidate2];
                if (* (const TAIL_T *) (_pCompare + _uCandidate2) == _uTailComperand)
                    goto L_Same2;

                _uCandidate2 = pNext[_uCandidate];
                if (* (const TAIL_T *) (_pCompare + _uCandidate) == _uTailComperand)
                    goto L_Same1;

#if DEEP_LOOKUP
                _uCandidate = pNext[_uCandidate2];
                if (* (const TAIL_T *) (_pCompare + _uCandidate2) == _uTailComperand)
                    goto L_Same2;
#else
                if (* (const TAIL_T *) (_pCompare + _uCandidate2) == _uTailComperand)
                    goto L_Same2;
                goto L_Done;
#endif /* DEEP_LOOKUP */
            }                                                                           
        }
    L_Same2:
        _uCandidate = _uCandidate2;
    L_Same1:

        if (_uCandidate >= uPosition)
            goto L_Done; //BUGBUG: why?

        pData += uPosition;

        {
            _iOffset  = _uCandidate - uPosition; // The distance of the match from the current position.

            _pCompare = pData;
            while (*_pCompare == _pCompare[_iOffset])
            {
                ++_pCompare;
                if (_pCompare >= pEndData)
                    goto L_DoneEof;
            }
                
            // If the length of current match is less than lookup table size, we need to verify that the match is no farther than the value in the 
            // look up table. The table is used to disallow any matches too far away. BUGBUG: Why?
            _uCandidate2 = (uxint) (_pCompare - pData);  // The length of the match.
            if (
                _uCandidate2 > uBestLength &&
                (_uCandidate2 > sizeof (s_iMaxOffsetByLength) / sizeof (s_iMaxOffsetByLength[0]) - 1 
                  || _iOffset > s_iMaxOffsetByLength[_uCandidate2])
            )
            {
                uBestLength = _uCandidate2;
                iBestOffset = _iOffset;
            }
        }

        pData -= uPosition;

#if DEEP_LOOKUP
        _uCandidate = pNext[_uCandidate];
#else
        goto L_Done;
#endif /* DEEP_LOOKUP */
    }
L_DoneEof:
    uBestLength = (uxint) (_pCompare - pData);
    iBestOffset = _iOffset;
    pData      -= uPosition;

L_Done:;
} while (0);
