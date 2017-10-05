

/*
 * mp_arith.c
 *
 */
#include <stdint.h>
// Calculates res = a + b.
// a and b represent large integers stored in uint32_t arrays
// a and b are arrays of size elements, res has size+1 elements
void mp_add(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
        uint32_t l_i32carry=0;
        uint32_t i;
        uint64_t buf_res=0;
        for(i=0;i<size;i++)
        {
            buf_res = (uint64_t)a[i] + (uint64_t)b[i] + (uint64_t)l_i32carry;
            l_i32carry=buf_res >>32;
            res[i]=(uint32_t)buf_res;
        }
        res[size]=l_i32carry;

}

// Calculates res = a - b.
// a and b represent large integers stored in uint32_t arrays
// a, b and res are arrays of size elements
void mp_sub(uint32_t *a, uint32_t *b, uint32_t *res, uint32_t size)
{
    uint32_t l_i32carry=0;
    uint32_t i;
    uint32_t buf_res=0;
    for(i=0;i<size;i++)
    {
        buf_res= (uint32_t)a[i] - (uint32_t)b[i] + (uint32_t)l_i32carry;
        if (buf_res >= 0x80000000)
            l_i32carry = -1;
        else
            l_i32carry = 0;
        res[i]=(uint32_t)buf_res;
    }

}

// Calculates res = (a + b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_add(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{
            uint32_t l_i32carry=0;
            uint32_t i;
            uint64_t buf_res=0;
            uint32_t dummy_res[size+1];
            uint32_t dummy_N[size+1];
            for(i=0;i<size;i++)
            {
                buf_res = (uint64_t)a[i] + (uint64_t)b[i] + (uint64_t)l_i32carry;
                l_i32carry=buf_res >>32;
                res[i]=(uint32_t)buf_res;
                dummy_N[i]=N[i];
            }
            dummy_res[size]=l_i32carry;
            dummy_N[size]=0;
            if(l_i32carry>0)
                mp_sub(dummy_res,dummy_N,res,size+1);
            else {
                for( i=size-1;i--;i=0){
                    if(res[i]>=N[i])
                        {mp_sub(dummy_res,dummy_N,res,size+1);
                        break;}
                    else {if(N[i]>0)
                        break;}


                }


            }

}

// Calculates res = (a - b) mod N.
// a and b represent operands, N is the modulus. They are large integers stored in uint32_t arrays of size elements
void mod_sub(uint32_t *a, uint32_t *b, uint32_t *N, uint32_t *res, uint32_t size)
{

}

