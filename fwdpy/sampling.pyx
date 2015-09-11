def ms_sample_single_deme(GSLrng rng, singlepop pop, int nsam, bint removeFixed):
    return take_sample_from_pop(rng.thisptr,pop.pop.get(),nsam, int(removeFixed))    


def ms_sample(GSLrng rng, poptype pop, int nsam, bint removeFixed = True):
    """
    Take a sample from a set of simulated populations.

    :param rng: a :class:`GSLrng`
    :param pops: An object inheriting from :class:`poptype`
    :param nsam: List of sample sizes (no. chromosomes) to sample.
    :param removeFixed: if True, only polymorphic sites are retained

    Note: nsam will likely be changed to a list soon, to accomodate multi-deme simulations
    
    Example:
    
    >>> import fwdpy
    >>> rng = fwdpy.GSLrng(100)
    >>> pop = fwdpy.evolve_pops_t(rng,3,1000,[1000]*1000,50,50)
    >>> s = [fwdpy.ms_sample(rng,i,10) for i in pop]
    """
    if isinstance(pop,singlepop):
        return ms_sample_single_deme(rng,pop,nsam,removeFixed)
    else:
        raise ValueError("ms_sample: unsupported type of popcontainer")

def get_sample_details( vector[pair[double,string]] ms_sample, singlepop pop ):
    """
    Get additional details for population samples

    :param ms_samples: A list returned by :func:`ms_sample`
    :param pops: A :class:`popvec` containing simulated populations

    :return: A pandas.DataFrame containing the selection coefficient (s), dominance (h), populations frequency (p), and age (a) for each mutation.

    :rtype: pandas.DataFrame

    Example:
    
    >>> import fwdpy
    >>> rng = fwdpy.GSLrng(100)
    >>> pop = fwdpy.evolve_pops_t(rng,3,1000,[1000]*1000,50,50)
    >>> s = [fwdpy.ms_sample(rng,i,10) for i in pop]
    >>> details = [fwdpy.get_sample_details(i,j) for i,j in zip(s,pop)]
    """
    cdef vector[double] h
    cdef vector[double] s
    cdef vector[double] p
    cdef vector[double] a
    get_sh(ms_sample,pop.pop.get(),&s,&h,&p,&a)
    return pandas.DataFrame({'s':s,'h':h,'p':p,'a':a})

def TajimasD( vector[pair[double,string]] data ):
    """
    Calculate Tajima's D statistic from a sample

    :param data: a sample from a population.  The return value of :func:`ms_sample`.

    Example:
    
    >>> import fwdpy
    >>> rng = fwdpy.GSLrng(100)
    >>> pop = fwdpy.evolve_pops_t(rng,3,1000,[1000]*1000,50,50)
    >>> s = [fwdpy.ms_sample(rng,i,10) for i in pop]
    >>> d = [fwdpy.TajimasD(si) for si in s]
    """
    return tajd(data)
